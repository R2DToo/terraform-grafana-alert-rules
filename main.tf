terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.0"
    }
  }
}

locals {
  regex_query = "(^[^<>]*) (<|>) (.+)"
  operator_translation = {
    "<" = "lt"
    ">" = "gt"
  }
  datasource = {
    prometheus = "grafanacloud-prom"
    loki       = "grafanacloud-logs"
  }
  model_config = {
    loki = {
      queryType     = "instant"
    }
    prometheus = {
      instant       = true
      legendFormat  = "__auto"
      range         = false
    }
  }
}

data "grafana_folder" "this" {
  title = var.folder_name
}

resource "grafana_rule_group" "this" {
  name             = var.name
  folder_uid       = data.grafana_folder.this.uid
  interval_seconds = 60

  dynamic "rule" {
    for_each = var.alert_rules

    content {
      name      = rule.value.name
      condition = "threshold"

      no_data_state  = "NoData"
      exec_err_state = "Error"
      for            = rule.value.window
      annotations = {
        summary     = rule.value.summary
        description = rule.value.description
      }
      labels    = {}
      is_paused = false


      data {
        ref_id = "query"

        relative_time_range {
          from = 600
          to   = 0
        }

        datasource_uid = local.datasource[rule.value.datasource]
        model = jsonencode(merge({
          editorMode    = "code"
          expr          = replace(regex(local.regex_query, rule.value.query)[0], "\n", "")
          intervalMs    = 1000
          maxDataPoints = 43200
          refId         = "query"
          hide          = false
        }, local.model_config[rule.value.datasource]))
      }
      data {
        ref_id = "threshold"

        relative_time_range {
          from = 600
          to   = 0
        }

        datasource_uid = "__expr__"
        model = jsonencode({
          conditions = [
            {
              evaluator = {
                params = [tonumber(regex(local.regex_query, rule.value.query)[2])]
                type   = local.operator_translation[regex(local.regex_query, rule.value.query)[1]]
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
