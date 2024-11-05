variable "rule_group_name" {
  description = "Name of the rule group"
  type        = string
}

variable "folder_name" {
  description = "Name of the folder where the rule group will be created"
  type        = string
}

variable "rule_group_frequency" {
  description = "How often to evaluate this rule group represented as seconds"
  type        = number
}

variable "alert_rules" {
  description = "List of alert rules to create, each with a name, summary, query, window, and description"
  type = list(object({
    name        = string
    datasource  = optional(string, "splunk")
    pending_period = string
    query       = string
    query_timerange = object({
      from = number
      to = optional(number, 0)
    })
    is_paused   = optional(boolean, false)
    condition_value = number
    condition_operator = string
    label_servicenow_dev = optional(string, "false")
    annotation_u_short_description = string
    annotation_u_description = string
    annotation_u_resource_id = string
    annotation_u_hostname = string
    annotation_u_service_id = string
    annotation_u_priority = string
    annotation_u_correlation_id = string
    annotation_u_trigger_callout = string
  }))
}
