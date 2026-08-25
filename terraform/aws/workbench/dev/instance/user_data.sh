#!/bin/bash
set -eux

# ==============================================================================
# System package updates and installations
# ==============================================================================
dnf -y update
dnf -y install dnf-plugins-core git python3.12 python3.12-pip tmux wget unzip
dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
dnf -y install gh
dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
dnf -y install terraform

# ==============================================================================
# Install uv and the Snowflake CLI
# ==============================================================================
# uv is the preferred modern Python toolchain for this environment. We install
# it first and then install the Snowflake CLI via uv so the tooling is managed
# consistently and can later be migrated away from pip entirely.
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
if ! command -v uv >/dev/null 2>&1; then
  echo "uv was not found in PATH after installation" >&2
  exit 1
fi
uv tool install --python python3.12 snowflake-cli
export PATH="$HOME/.local/bin:$PATH"
if ! command -v snow >/dev/null 2>&1; then
  echo "Snowflake CLI was not found in PATH after installation" >&2
  exit 1
fi
snow --version

# ==============================================================================
# Configure 2GB swap to reduce OOM risk on small instance types
# ==============================================================================
if [ ! -f /swapfile ]; then
  if command -v fallocate >/dev/null 2>&1; then
    fallocate -l 2G /swapfile
  else
    dd if=/dev/zero of=/swapfile bs=1M count=2048
  fi
  chmod 600 /swapfile
  mkswap /swapfile
fi

if ! swapon --show=NAME | grep -q '^/swapfile$'; then
  swapon /swapfile
fi

if ! grep -q '^/swapfile none swap sw 0 0$' /etc/fstab; then
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

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
# Generate Snowflake CLI config.toml for AWS IAM Workload Identity
# ==============================================================================
owner_slug_upper=$(echo "${owner_slug}" | tr '[:lower:]' '[:upper:]')

mkdir -p /home/ec2-user/.config/snowflake
cat >/home/ec2-user/.config/snowflake/config.toml <<EOF
default_connection_name = "default"

[cli.logs]
save_logs = true
path = "/home/ec2-user/.config/snowflake/logs"
level = "info"

[connections.default]
account = "${sf_organization_name}-${sf_account_name}"
user = "WORKBENCH_$${owner_slug_upper}_USER"
warehouse = "WORKBENCH_$${owner_slug_upper}_WH"
role = "WORKBENCH_$${owner_slug_upper}_ROLE"
authenticator = "WORKLOAD_IDENTITY"
workload_identity_provider = "AWS"
EOF

chown -R ec2-user:ec2-user /home/ec2-user/.config/snowflake
chmod 600 /home/ec2-user/.config/snowflake/config.toml

# ==============================================================================
# MANUAL STEPS (after EC2 startup):
# ==============================================================================
# 1. On EC2 (SSM), run: gh auth login
# 2. In EC2 terminal: git clone https://github.com/YOUR_REPO.git
# ==============================================================================
