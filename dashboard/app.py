#!/usr/bin/env python3
# ==============================================================================
# METASPLOIT INSTALLER DASHBOARD — Flask + SocketIO Web Interface (SECURED)
# ==============================================================================
from flask import Flask, render_template, request, jsonify, send_from_directory
from flask_socketio import SocketIO, emit
import os
import subprocess
import threading
import json
import time
from pathlib import Path
import shlex

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'msf-dashboard-secret-change-me')
# Disable CORS wildcard for security - restrict to localhost
socketio = SocketIO(app, cors_allowed_origins=["http://localhost:5000", "http://127.0.0.1:5000"], async_mode='threading')

# Project directories
PROJECT_DIR = Path(__file__).parent.parent
MODULES_DIR = PROJECT_DIR / 'modules'
SCRIPTS_DIR = PROJECT_DIR / 'scripts'

# Background scan processes
active_scans = {}

# Security: Command allowlist - only allow specific safe commands
ALLOWED_MODULES = {
    'scanner', 'exploit', 'post', 'gather', 'evasion', 'kerberos', 'relay', 'c2', 'cracking', 'cloud', 'container', 'client_side', 'auxiliary'
}

def run_command_safe(cmd_list, cwd=None, scan_id=None):
    """Run command safely without shell=True - uses list arguments only"""
    try:
        proc = subprocess.Popen(
            cmd_list,  # List format, NO shell=True
            cwd=cwd or PROJECT_DIR,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
            text=True, bufsize=1
        )
        
        for line in proc.stdout:
            line = line.rstrip()
            if scan_id:
                socketio.emit('scan_output', {'scan_id': scan_id, 'line': line})
            else:
                socketio.emit('command_output', {'line': line})
        
        proc.wait()
        if scan_id:
            socketio.emit('scan_complete', {'scan_id': scan_id, 'status': 'completed' if proc.returncode == 0 else 'failed'})
        return proc.returncode
    except Exception as e:
        if scan_id:
            socketio.emit('scan_error', {'scan_id': scan_id, 'error': str(e)})
        return -1

def validate_module_path(module_path):
    """Validate module path to prevent path traversal"""
    # Only allow alphanumeric, dash, underscore, slash
    if not module_path or '..' in module_path or module_path.startswith('/'):
        return False
    parts = module_path.split('/')
    if len(parts) < 3:
        return False
    # Category must be in allowed list
    if parts[0] not in ALLOWED_MODULES:
        return False
    # No shell metacharacters
    for part in parts:
        if not part.replace('-', '').replace('_', '').isalnum():
            return False
    return True

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/modules')
def api_modules():
    """Get all available modules organized by category"""
    modules = {}
    
    for category_dir in MODULES_DIR.iterdir():
        if not category_dir.is_dir():
            continue
        if category_dir.name not in ALLOWED_MODULES:
            continue
        
        modules[category_dir.name] = []
        
        for subcat_dir in category_dir.iterdir():
            if not subcat_dir.is_dir():
                continue
            
            for module_file in subcat_dir.glob('*.sh'):
                modules[category_dir.name].append({
                    'name': module_file.stem.replace('_', ' ').title(),
                    'path': f"{category_dir.name}/{subcat_dir.name}/{module_file.stem}",
                    'category': category_dir.name,
                    'subcategory': subcat_dir.name
                })
    
    return jsonify(modules)

@app.route('/api/modules/run', methods=['POST'])
def api_run_module():
    """Run a module safely"""
    data = request.get_json()
    module_path = data.get('module')
    args = data.get('args', [])
    
    if not module_path:
        return jsonify({'error': 'Module path required'}), 400
    
    # Validate module path
    if not validate_module_path(module_path):
        return jsonify({'error': 'Invalid module path'}), 400
    
    module_file = MODULES_DIR / f"{module_path}.sh"
    if not module_file.exists():
        return jsonify({'error': 'Module not found'}), 404
    
    # Build safe command list
    cmd = ['bash', str(module_file)] + [str(arg) for arg in args]
    
    def run_and_capture():
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, cwd=PROJECT_DIR, timeout=300)
            output = result.stdout
            if result.stderr:
                output += '\n' + result.stderr
            socketio.emit('module_complete', {
                'module': module_path,
                'output': output,
                'success': result.returncode == 0
            })
        except subprocess.TimeoutExpired:
            socketio.emit('module_complete', {
                'module': module_path,
                'output': 'Timeout after 5 minutes',
                'success': False
            })
        except Exception as e:
            socketio.emit('module_complete', {
                'module': module_path,
                'output': f'Error: {str(e)}',
                'success': False
            })
    
    threading.Thread(target=run_and_capture, daemon=True).start()
    return jsonify({'started': True})

@app.route('/api/scripts')
def api_scripts():
    """Get available scripts"""
    scripts = []
    if SCRIPTS_DIR.exists():
        for script in SCRIPTS_DIR.glob('*.sh'):
            scripts.append({
                'name': script.stem.replace('_', ' ').title(),
                'file': script.name,
                'path': str(script)
            })
    return jsonify(scripts)

@app.route('/api/scripts/run', methods=['POST'])
def api_run_script():
    """Run a script safely"""
    data = request.get_json()
    script_name = data.get('script')
    args = data.get('args', [])
    
    if not script_name:
        return jsonify({'error': 'Script name required'}), 400
    
    # Validate script name
    if '..' in script_name or '/' in script_name or not script_name.endswith('.sh'):
        return jsonify({'error': 'Invalid script name'}), 400
    
    script_path = SCRIPTS_DIR / script_name
    if not script_path.exists():
        return jsonify({'error': 'Script not found'}), 404
    
    cmd = ['bash', str(script_path)] + [str(arg) for arg in args]
    
    def run_script():
        result = subprocess.run(cmd, capture_output=True, text=True, cwd=PROJECT_DIR, timeout=600)
        socketio.emit('script_complete', {
            'script': script_name,
            'output': result.stdout,
            'error': result.stderr,
            'success': result.returncode == 0
        })
    
    threading.Thread(target=run_script, daemon=True).start()
    return jsonify({'started': True})

@app.route('/api/status')
def api_status():
    """Get system status"""
    status = {
        'msf_installed': os.path.exists(os.path.expanduser('~/bin/msfconsole')),
        'msf_dir': os.path.exists(os.path.expanduser('~/metasploit-framework')),
        'db_connected': False,
        'postgres_running': False
    }
    
    # Check PostgreSQL
    try:
        result = subprocess.run(['pg_isready', '-p', '5432'], capture_output=True, timeout=5)
        status['postgres_running'] = result.returncode == 0
    except:
        pass
    
    # Check msf db
    try:
        msfconsole = os.path.expanduser('~/bin/msfconsole')
        if os.path.exists(msfconsole):
            result = subprocess.run([msfconsole, '-q', '-x', 'db_status; exit'], capture_output=True, text=True, timeout=30)
            status['db_connected'] = 'connected' in result.stdout.lower()
    except:
        pass
    
    return jsonify(status)

# ── NEW: Scan API ─────────────────────────────────────────────────────────────
@app.route('/api/scan', methods=['POST'])
def api_scan():
    """Start a network scan (nmap)"""
    data = request.get_json()
    target = data.get('target', '')
    scan_type = data.get('type', 'quick')
    
    if not target:
        return jsonify({'error': 'Target required'}), 400
    
    # Validate target - basic check
    import re
    if not re.match(r'^[\w\.\-\/]+$', target):
        return jsonify({'error': 'Invalid target format'}), 400
    
    scan_id = f"scan_{int(time.time())}"
    
    if scan_type == 'quick':
        cmd = ['nmap', '-sS', '-T4', '--top-ports', '100', target]
    else:
        cmd = ['nmap', '-sS', '-sV', '-O', '-p-', target]
    
    def run_scan():
        run_command_safe(cmd, scan_id=scan_id)
    
    active_scans[scan_id] = {'cmd': cmd, 'target': target, 'type': scan_type}
    threading.Thread(target=run_scan, daemon=True).start()
    
    return jsonify({'scan_id': scan_id, 'started': True})

# ── NEW: MSF Console API ──────────────────────────────────────────────────────
@app.route('/api/msfconsole', methods=['POST'])
def api_msfconsole():
    """Run a command in msfconsole"""
    data = request.get_json()
    command = data.get('command', '')
    
    if not command:
        return jsonify({'error': 'Command required'}), 400
    
    # Validate command - no shell metacharacters
    if any(c in command for c in [';', '|', '&', '$', '`', '>', '<']):
        return jsonify({'error': 'Invalid command - no shell metacharacters allowed'}), 400
    
    msfconsole = os.path.expanduser('~/bin/msfconsole')
    if not os.path.exists(msfconsole):
        return jsonify({'error': 'msfconsole not installed. Run setup.sh first.'}), 404
    
    # Run MSF command
    cmd = [msfconsole, '-q', '-x', f'{command}; exit']
    
    def run_msf():
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, cwd=PROJECT_DIR, timeout=60)
            socketio.emit('msf_output', {
                'command': command,
                'output': result.stdout,
                'error': result.stderr,
                'success': result.returncode == 0
            })
        except subprocess.TimeoutExpired:
            socketio.emit('msf_output', {
                'command': command,
                'output': 'Timeout after 60 seconds',
                'error': '',
                'success': False
            })
        except Exception as e:
            socketio.emit('msf_output', {
                'command': command,
                'output': f'Error: {str(e)}',
                'error': '',
                'success': False
            })
    
    threading.Thread(target=run_msf, daemon=True).start()
    return jsonify({'started': True})

@app.route('/static/<path:filename>')
def static_files(filename):
    return send_from_directory(os.path.join(os.path.dirname(__file__), 'static'), filename)

@socketio.on('connect')
def handle_connect():
    print(f'Client connected: {request.sid}')

@socketio.on('disconnect')
def handle_disconnect():
    print(f'Client disconnected: {request.sid}')

if __name__ == '__main__':
    # Create templates and static dirs
    os.makedirs(os.path.join(os.path.dirname(__file__), 'templates'), exist_ok=True)
    os.makedirs(os.path.join(os.path.dirname(__file__), 'static'), exist_ok=True)
    
    print("Starting Metasploit Dashboard on http://localhost:5000")
    # Only bind to localhost for security
    socketio.run(app, host='127.0.0.1', port=5000, debug=False)
