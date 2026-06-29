#!/bin/bash

set -e

# Root check
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] Please run as root."
    exit 1
fi

CONFIG="/etc/ssh/sshd_config"

echo "[1/6] Installing OpenSSH Server..."

export DEBIAN_FRONTEND=noninteractive

apt update -y
apt install -y openssh-server

echo "[2/6] Creating required directories..."

mkdir -p /var/run/sshd
mkdir -p /root/.ssh

chmod 700 /root/.ssh

echo "[3/6] Generating host keys..."

ssh-keygen -A

echo "[4/6] Checking sshd configuration..."

# Port 22
if ! grep -Eq "^Port[[:space:]]+22$" "$CONFIG"; then
    echo "" >> "$CONFIG"
    echo "# Added by AAC SSH Fix" >> "$CONFIG"
    echo "Port 22" >> "$CONFIG"
fi

# Root login
if ! grep -Eq "^PermitRootLogin[[:space:]]+yes$" "$CONFIG"; then
    echo "PermitRootLogin yes" >> "$CONFIG"
fi

echo "[5/6] Validating configuration..."

sshd -t

echo "[6/6] Starting SSH daemon..."

if pgrep -x sshd >/dev/null; then
    echo "sshd is already running."
else
    /usr/sbin/sshd -E /var/log/sshd.log
fi

echo
echo "=========================================="
echo " SSH setup completed"
echo "=========================================="

# check sshd
if pgrep -x sshd >/dev/null; then
    echo "[OK] sshd process is running."
else
    echo "[WARNING] sshd process not detected."
fi

# if have ss command
if command -v ss >/dev/null 2>&1; then
    echo
    echo "Listening ports:"
    ss -tln | grep ":22 " || \
    echo "[NOTICE] Port 22 not found in ss output."
else
    echo
    echo "[NOTICE] 'ss' command not found (iproute2 not installed)."
    echo "Skipping port listening check."
fi

echo
echo "Host keys:"
ls -1 /etc/ssh/ssh_host_* 2>/dev/null || true

echo
echo "SSH log:"
echo "  /var/log/sshd.log"

echo
echo "Done."