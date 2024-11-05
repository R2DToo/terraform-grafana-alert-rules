terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.0"
    }
  }
}

locals {
  operator_translation = {
    "<" = "lt"
    ">" = "gt"
  }
  datasource = {
    splunk = "ddybapuid8nwgc"
    mssql = "be1r64e3uo9hce"
  }
  model_config = {
    splunk = {
      query = rule.value.query
    }
    mssql = {
      rawQuery = true
      rawSql = rule.value.query
    }
  }
}

data "grafana_folder" "this" {
  title = var.folder_name
}

resource "grafana_rule_group" "this" {
  name             = var.rule_group_name
  folder_uid       = data.grafana_folder.this.uid
  interval_seconds = var.rule_group_frequency

  dynamic "rule" {
    for_each = var.alert_rules

    content {
      name      = rule.value.name
      condition = "threshold"

      no_data_state  = "NoData"
      exec_err_state = "Error"
      for            = rule.value.pending_period
      annotations = {
        u_short_description = rule.value.annotation_u_short_description
        u_description = rule.value.annotation_u_description
        u_resource_id = rule.value.annotation_u_resource_id
        u_hostname = rule.value.annotation_u_hostname
        u_service_id = rule.value.annotation_u_service_id
        u_priority = rule.value.annotation_u_priority
        u_correlation_id = rule.value.annotation_u_correlation_id
        u_trigger_callout = rule.value.annotation_u_trigger_callout
      }
      labels    = {
        servicenow_dev = rule.value.label_servicenow_dev
      }
      is_paused = rule.value.is_paused

      data {
        ref_id = "query"

        relative_time_range {
          from = rule.value.query_timerange.from
          to   = rule.value.query_timerange.to
        }

        datasource_uid = local.datasource[rule.value.datasource]
        model = jsonencode(merge({
          intervalMs    = 1000
          maxDataPoints = 43200
          refId         = "query"
        }, local.model_config[rule.value.datasource]))
      }

      data {
        ref_id = "threshold"

        relative_time_range {
          from = rule.value.query_timerange.from
          to   = rule.value.query_timerange.to
        }

        datasource_uid = "__expr__"
        model = jsonencode({
          conditions = [
            {
              evaluator = {
                params = rule.value.condition_value
                type   = local.operator_translation[rule.value.condition_operator]
              },
              operator = {
                type = "and",
              },
              query = {
                params = ["C"],
              },
              reducer = {
                params = [],
                type   = "last",
              },
              type = "query",
            },
          ],
          datasource = {
            type = "__expr__",
            uid  = "__expr__",
          },
          expression    = "query",
          intervalMs    = 1000,
          maxDataPoints = 43200,
          refId         = "threshold",
          type          = "threshold",
        })
      }
    }
  }
}
