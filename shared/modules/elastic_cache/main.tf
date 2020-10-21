# parameter group vars
variable "is_create_parameter_group" {
  type    = bool
  default = false
}
variable "parameter_group_vars" {
  type = object(
    {
      family = string,
      parameters = list(object(
        {
          name  = string
          value = string
        }
      ))
    }
  )
  default = null
}
# subnet group vars
variable "is_create_subnet_group" {
  type    = bool
  default = false
}
variable "subnet_ids" {
  type    = list(string)
  default = []
}
# repl group vars
variable "is_create_repl_group" {
  type    = bool
  default = false
}
variable "repl_group_vars" {
  type = object(
    {
      engine                   = string,
      engine_version           = string,
      number_cache_clusters    = number,
      node_type                = string,
      snapshot_window          = string,
      snapshot_retention_limit = number,
      maintenance_window       = string,
      port                     = number,
      apply_immediately        = bool,
    }
  )
}
variable "security_group_ids" {
  type    = list(string)
  default = []
}
variable "parameter_group_name" {
  type    = string
  default = ""
}
variable "subnet_group_name" {
  type    = string
  default = ""
}
variable "pjprefix" {
  type    = string
  default = ""
}

module "parameter_group" {
  count = var.is_create_parameter_group ? 1 : 0

  source     = "./parameter_group"
  name       = "params-group-${var.pjprefix}"
  family     = lookup(var.parameter_group_vars, "family", null)
  parameters = lookup(var.parameter_group_vars, "parameters", null)
}

module "subnet_group" {
  count = var.is_create_subnet_group ? 1 : 0

  source     = "./subnet_group"
  name       = "subnet-group-${var.pjprefix}"
  subnet_ids = var.subnet_ids
}

module "repl_group" {
  count = var.is_create_repl_group ? 1 : 0

  source                     = "./repl_group"
  repl_id                    = "repl-group-${var.pjprefix}"
  engine                     = lookup(var.repl_group_vars, "engine", null)
  engine_version             = lookup(var.repl_group_vars, "engine_version", null)
  number_cache_clusters      = lookup(var.repl_group_vars, "number_cache_clusters", null)
  node_type                  = lookup(var.repl_group_vars, "node_type", null)
  snapshot_window            = lookup(var.repl_group_vars, "snapshot_window", null)
  snapshot_retention_limit   = lookup(var.repl_group_vars, "snapshot_retention_limit", null)
  maintenance_window         = lookup(var.repl_group_vars, "maintenance_window", null)
  automatic_failover_enabled = lookup(var.repl_group_vars, "automatic_failover_enabled", null)
  port                       = lookup(var.repl_group_vars, "port", null)
  apply_immediately          = lookup(var.repl_group_vars, "apply_immediately", null)
  security_group_ids         = var.security_group_ids
  parameter_group_name       = var.is_create_parameter_group ? module.parameter_group[0].name : var.parameter_group_name
  subnet_group_name          = var.is_create_subnet_group ? module.subnet_group[0].name : var.subnet_group_name
}

output "parameter_group_id" {
  value = var.is_create_parameter_group ? "${module.parameter_group[0].id}" : ""
}
output "parameter_group_name" {
  value = var.is_create_parameter_group ? "${module.parameter_group[0].name}" : ""
}
output "subnet_group_name" {
  value = var.is_create_subnet_group ? module.subnet_group[0].name : ""
}
