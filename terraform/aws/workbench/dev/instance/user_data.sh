#!/bin/bash
set -eux

# ==============================================================================
# System package updates and installations
# ==============================================================================
dnf -y update
dnf -y install dnf-plugins-core git python3.12 python3.12-pip tmux
dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
dnf -y install gh

# ==============================================================================
# Install VSCode CLI (for Remote Tunnel)
# ==============================================================================
rpm --import https://packages.microsoft.com/keys/microsoft.asc
cat >/etc/yum.repos.d/vscode.repo <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
dnf check-update || true
dnf -y install code

sudo -u ec2-user bash <<'VSCODE_INSTALL'
mkdir -p ~/.local/bin
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

cat > ~/.local/bin/start-vscode-tunnel-service <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

TUNNEL_NAME=$(ec2-metadata --instance-id | cut -d ' ' -f 2)

# Check if already authenticated
if [ -f ~/.vscode/cli/code_tunnel.json ]; then
  echo "✓ Already authenticated. Starting tunnel service..."
  systemctl --user daemon-reload
  systemctl --user enable --now vscode-tunnel.service
  systemctl --user status vscode-tunnel.service --no-pager
else
  echo "=========================================="
  echo "VS Code Tunnel - Initial Authentication"
  echo "=========================================="
  echo ""
  echo "Tunnel name: $TUNNEL_NAME"
  echo ""
  echo "GitHub authentication required."
  echo "Please follow the instructions below:"
  echo ""
  
  # Run code tunnel in background for authentication
  # Using nohup & to detach from TTY so it survives SSM session disconnection
  nohup /usr/bin/code tunnel --name "$TUNNEL_NAME" --accept-server-license-terms > ~/.code-tunnel.log 2>&1 &
  sleep 2
  
  echo ""
  echo "=========================================="
  echo "Waiting for authentication code..."
  echo "=========================================="
  echo ""
  
  # Show the live log so user can see the auth code
  tail -f ~/.code-tunnel.log
  
  # After user stops tail with Ctrl+C, start the systemd service
  echo ""
  echo "=========================================="
  echo "Starting tunnel service in background..."
  echo "=========================================="
  systemctl --user daemon-reload
  systemctl --user enable --now vscode-tunnel.service
  sleep 2
  systemctl --user status vscode-tunnel.service --no-pager
  
  echo ""
  echo "=========================================="
  echo "✓ VS Code tunnel is now running."
  echo "✓ You can safely close this SSM session."
  echo "✓ Your local VS Code tunnel will continue"
  echo "  working in the background."
  echo "=========================================="
fi
EOF
chmod +x ~/.local/bin/start-vscode-tunnel-service

mkdir -p ~/.config/systemd/user
mkdir -p ~/.local/bin

cat > ~/.local/bin/vscode-tunnel-start.sh <<'EOF'
#!/bin/bash
set -euo pipefail
TUNNEL_NAME=$(ec2-metadata --instance-id | cut -d ' ' -f 2)
/usr/bin/code tunnel --name "$TUNNEL_NAME" --accept-server-license-terms
EOF
chmod +x ~/.local/bin/vscode-tunnel-start.sh

cat > ~/.config/systemd/user/vscode-tunnel.service <<'EOF'
[Unit]
Description=VS Code Tunnel
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=%h/.local/bin/vscode-tunnel-start.sh
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF
VSCODE_INSTALL

loginctl enable-linger ec2-user

# ==============================================================================
# Python tools installation
# ==============================================================================
python3.12 -m pip install --upgrade pip
cat << EOF > /tmp/requirements.txt
${requirements_content}
EOF
python3.12 -m pip install -r /tmp/requirements.txt

# ==============================================================================
# Configure persistent dbt log path
# ==============================================================================
sudo -u ec2-user bash <<'DBT_LOG_CONFIG'
echo 'export DBT_LOG_PATH="$HOME/private-fin-data-platform/dbt/logs"' >> ~/.bashrc
DBT_LOG_CONFIG

# ==============================================================================
# Generate dbt profiles.yml for AWS IAM Workload Identity
# ==============================================================================
mkdir -p /home/ec2-user/.dbt
cat >/home/ec2-user/.dbt/profiles.yml <<EOF
private_fin_data_platform:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: ${sf_organization_name}-${sf_account_name}
      authenticator: WORKLOAD_IDENTITY
      workload_identity_provider: AWS
      # The Snowflake workbench service user created by Terraform already has a
      # default role configured, so leave role unset here.
      warehouse: workbench_${owner_slug}_wh
      database: DATAWAREHOUSE_DB
      schema: ${owner_slug}
      threads: 4
EOF

chown ec2-user:ec2-user /home/ec2-user/.dbt/profiles.yml
chmod 600 /home/ec2-user/.dbt/profiles.yml

# ==============================================================================
# MANUAL STEPS (after EC2 startup):
# ==============================================================================
# 1. In local VSCode, install "Remote - Tunnels" extension
# 2. On EC2 (SSM), run: gh auth login
# 3. On EC2 (SSM), run: start-vscode-tunnel-service
# 4. Connect from local VSCode or browser (vscode.dev)
# 5. In EC2 terminal (via Tunnel): git clone https://github.com/YOUR_REPO.git
# ==============================================================================
