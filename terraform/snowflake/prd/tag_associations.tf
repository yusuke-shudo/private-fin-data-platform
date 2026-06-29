# Old centralized tag associations replaced by per-resource associations in individual tf files.
# database_managed_by / schema_managed_by / integration_object_managed_by are destroyed normally.
# stage_object_managed_by uses destroy=false because PAYPAY_BANK_STAGE is being recreated.
# Delete this file in Step 2.

removed {
  from = snowflake_tag_association.stage_object_managed_by
  lifecycle {
    destroy = false
  }
}