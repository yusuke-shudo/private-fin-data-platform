-- schemachange migration: create DATAWAREHOUSE schemas for staging and core layers
-- This file establishes the schema structure for data transformation pipeline

CREATE SCHEMA IF NOT EXISTS DATAWAREHOUSE_DB.STAGING
  COMMENT = 'Schema for standardized and cleaned staging tables';

CREATE SCHEMA IF NOT EXISTS DATAWAREHOUSE_DB.CORE
  COMMENT = 'Schema for core business entities and dimensions';

CREATE SCHEMA IF NOT EXISTS DATAWAREHOUSE_DB.MART
  COMMENT = 'Schema for domain-specific analytics tables';
