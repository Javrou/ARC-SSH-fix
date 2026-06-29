# ARC SSH Fix

Fixes the common "Connection refused" issue on AMD Radeon Cloud (ARC).

## Symptoms

ARC provides:

- Public IP
- SSH Port

But SSH login fails:

```bash
ssh root@<ip> -p <port>
Connection refused
```

## Cause

AAC only provides port mapping.

The container must:

1. Install OpenSSH Server
2. Run sshd
3. Listen on port 22

Otherwise the connection will be refused.

## Usage

```bash
wget https://raw.githubusercontent.com/Javrou/ARC-SSH-fix/main/start_ssh.sh

chmod +x start_ssh.sh

./start_ssh.sh
```
