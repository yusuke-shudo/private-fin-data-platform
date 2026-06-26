-- schemachange migration: create DATAMART schemas for analytics and reporting
-- This file establishes the schema structure for analytics and reporting layer

CREATE SCHEMA IF NOT EXISTS DATAMART_DB.PERSONAL_ASSETS
  COMMENT = 'Schema for personal asset portfolio analytics';

CREATE SCHEMA IF NOT EXISTS DATAMART_DB.INVESTMENT_PERFORMANCE
  COMMENT = 'Schema for investment performance and returns analysis';
