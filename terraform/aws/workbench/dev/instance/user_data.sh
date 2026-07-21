#!/bin/bash
set -eux

# ==============================================================================
# System package updates and installations
# ==============================================================================
dnf -y update
dnf -y install dnf-plugins-core git python3.14 python3.14-pip
dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
dnf -y install gh

# ==============================================================================
# Install VSCode CLI (for Remote Tunnel)
# ==============================================================================
sudo -u ec2-user bash <<'VSCODE_INSTALL'
mkdir -p ~/.local/bin ~/.local/share/vscode-cli
cd ~/.local/share/vscode-cli
curl -L 'https://code.visualstudio.com/sha/download?build=stable&os=cli-linux-arm64' -o vscode-cli.tar.gz
tar -xzf vscode-cli.tar.gz
ln -sf ~/.local/share/vscode-cli/code ~/.local/bin/code
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
VSCODE_INSTALL

# ==============================================================================
# Python tools installation
# ==============================================================================
python3.14 -m pip install --upgrade pip
python3.14 -m pip install dbt-core dbt-snowflake sqlfluff

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
      user: workbench_${owner}_user
      authenticator: WORKLOAD_IDENTITY
      workload_identity_provider: AWS
      role: workbench_${owner}_role
      warehouse: workbench_${owner}_wh
      database: DATAWAREHOUSE_DB
      schema: STAGING
      threads: 4
EOF

chown ec2-user:ec2-user /home/ec2-user/.dbt/profiles.yml
chmod 600 /home/ec2-user/.dbt/profiles.yml

# ==============================================================================
# MANUAL STEPS (after EC2 startup):
# ==============================================================================
# 1. In local VSCode, install "Remote - Tunnels" extension
# 2. On EC2, run: code tunnel --name <tunnel-name>
# 3. Authenticate with GitHub when prompted
# 4. Connect from local VSCode or browser (vscode.dev)
# 5. In EC2 terminal (via Tunnel): git clone https://github.com/YOUR_REPO.git
# ==============================================================================
