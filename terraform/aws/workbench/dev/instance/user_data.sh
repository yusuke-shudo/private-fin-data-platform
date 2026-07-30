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
# 1. On EC2 (SSM), run: gh auth login
# 2. In EC2 terminal: git clone https://github.com/YOUR_REPO.git
# ==============================================================================
