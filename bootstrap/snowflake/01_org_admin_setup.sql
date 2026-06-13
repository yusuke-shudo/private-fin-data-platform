-- ==============================================================================
-- 1. 組織アカウントでの手作業（実行ロール: ORGADMIN / SYSADMIN）
-- ==============================================================================

-- [SYSADMIN] 組織アカウント専用の共通ウェアハウス設定
USE ROLE SYSADMIN;

CREATE OR REPLACE WAREHOUSE compute_wh
  GENERATION = '1'
  AUTO_SUSPEND = 60
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'The only operational warehouse in the organization account'
;

-- [ORGADMIN] 子アカウント作成
USE ROLE ORGADMIN;

CREATE ACCOUNT private_fin_data_platform_dev
  ADMIN_NAME = yusuke_shudo
  ADMIN_PASSWORD = '<YourSecurePassword123!>' -- 実行時に要書き換え
  ADMIN_USER_TYPE = PERSON
  FIRST_NAME = 'Yusuke'
  LAST_NAME = 'Shudo'
  EMAIL = 'admin@yourdomain.com'  -- 実行時に要書き換え
  MUST_CHANGE_PASSWORD = TRUE
  EDITION = ENTERPRISE 
  REGION = aws_ap_northeast_1
  COMMENT = 'DEV environment for Personal Financial Data Platform'
;

CREATE ACCOUNT private_fin_data_platform_prd
  ADMIN_NAME = yusuke_shudo
  ADMIN_PASSWORD = '<YourSecurePassword123!>' -- 実行時に要書き換え
  ADMIN_USER_TYPE = PERSON
  FIRST_NAME = 'Yusuke'
  LAST_NAME = 'Shudo'
  EMAIL = 'admin@yourdomain.com'  -- 実行時に要書き換え
  MUST_CHANGE_PASSWORD = TRUE
  EDITION = ENTERPRISE 
  REGION = aws_ap_northeast_1
  COMMENT = 'PRD environment for Personal Financial Data Platform'
;
