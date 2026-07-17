#!/usr/bin/env python3
"""
Upload dbt project archive to Snowflake internal stage
"""

import os
import sys
from pathlib import Path
from snowflake.connector import connect

def upload_dbt_project_to_stage():
    """Upload dbt project tar.gz to Snowflake internal stage"""
    
    # Environment variables
    account = os.getenv('SNOWFLAKE_ACCOUNT')
    user = os.getenv('SNOWFLAKE_USER', 'cicd_data_engineer_user')
    role = os.getenv('SNOWFLAKE_ROLE', 'cicd_data_engineer_role')
    warehouse = os.getenv('SNOWFLAKE_WAREHOUSE', 'cicd_data_wh')
    token = os.getenv('SNOWFLAKE_TOKEN')
    run_id = os.getenv('GITHUB_RUN_ID', 'local-test')
    event_name = os.getenv('GITHUB_EVENT_NAME', 'manual')
    
    if not token:
        print("ERROR: SNOWFLAKE_TOKEN not set")
        sys.exit(1)
    
    if not account:
        print("ERROR: SNOWFLAKE_ACCOUNT not set")
        sys.exit(1)
    
    # Determine stage path based on event
    if event_name == 'pull_request':
        stage_path = f"pr-{run_id}"
    else:
        stage_path = f"main-{run_id}"
    
    archive_file = "dbt-project.tar.gz"
    
    if not Path(archive_file).exists():
        print(f"ERROR: {archive_file} not found")
        sys.exit(1)
    
    print(f"Connecting to Snowflake: {account}")
    
    try:
        conn = connect(
            account=account,
            user=user,
            authenticator='workload_identity',
            workload_identity_provider='OIDC',
            token=token,
            role=role,
            warehouse=warehouse
        )
        
        cursor = conn.cursor()
        
        # Create stage if not exists
        cursor.execute("""
            CREATE STAGE IF NOT EXISTS DBT_PROJECT_STAGE
            DIRECTORY = ( ENABLE = TRUE )
        """)
        
        # Upload file
        print(f"Uploading {archive_file} to @DBT_PROJECT_STAGE/{stage_path}/")
        cursor.execute(
            f"PUT file://{archive_file} @DBT_PROJECT_STAGE/{stage_path}/ OVERWRITE = TRUE"
        )
        
        # Get upload result
        result = cursor.fetchone()
        print(f"Upload result: {result}")
        
        cursor.close()
        conn.close()
        
        print(f"✓ Successfully uploaded to @DBT_PROJECT_STAGE/{stage_path}/{archive_file}")
        
    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)

if __name__ == "__main__":
    upload_dbt_project_to_stage()
