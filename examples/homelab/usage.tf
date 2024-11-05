module "grafana_alerts" {
  source = "./module"

  rule_group_name = "Terraform Testing"
  folder_name = "Development"
  rule_group_frequency = 60

  alert_rules = [
    {
      name        = "TT Oracle Recovery Space Low"
      datasource  = "splunk"
      pending_period = "1m"
      query       = "index=losprd sourcetype=oracle:recoverySpacenn| lookup snow_cmdb_servers_services_ip_master.csv ip_address as host OUTPUT name sys_idnn| stats latest(PERCENT_SPACE_USED) AS PERCENT_SPACE_USED by name sys_idnn| where PERCENT_SPACE_USED u003c= 90nn| table name PERCENT_SPACE_USED sys_id"
      query_timerange = {
        from = 3600
        to = 0
      }
      is_paused   = true
      condition_value = "90"
      condition_operator = ">"
      label_servicenow_dev = "false"
      annotation_u_short_description = ""
      annotation_u_description = ""
      annotation_u_resource_id = ""
      annotation_u_hostname = ""
      annotation_u_service_id = ""
      annotation_u_priority = ""
      annotation_u_correlation_id = ""
      annotation_u_trigger_callout = ""
    }
  ]
}