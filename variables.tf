variable "name" {
  description = "Name of the rule group"
  type        = string
}

variable "folder_name" {
  description = "Name of the folder where the rule group will be created"
  type        = string
}

variable "alert_rules" {
  description = "List of alert rules to create, each with a name, summary, query, window, and description"
  type = list(object({
    name        = string
    summary     = string
    query       = string
    window      = string
    description = string
  }))
}
