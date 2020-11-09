variable "parameter_group_params" {
  type    = any
  default = null
}
variable "option_group_params" {
  type    = any
  default = null
}
variable "subnet_group_params" {
  type    = any
  default = null
}
variable "aurora_cluster_params" {
  type    = any
  default = null
}
variable "aurora_cluster_identifier" {
  type    = string
  default = null
}
variable "aurora_security_group_ids" {
  type    = list(string)
  default = []
}
variable "pjprefix" {
  type    = string
  default = ""
}

module "db_parameter_group" {
  count = var.parameter_group_params == null ? 0 : 1

  source     = "./parameter_group"
  parameters = lookup(var.parameter_group_params, "parameters", null)
  name       = lookup(var.parameter_group_params, "name", null)
  family     = lookup(var.parameter_group_params, "family", null)
  is_cluster = true
  pjprefix   = var.pjprefix
}

module "db_option_group" {
  count = var.option_group_params == null ? 0 : 1

  source               = "./option_group"
  name                 = lookup(var.option_group_params, "name", null)
  engine_name          = lookup(var.option_group_params, "engine_name", null)
  major_engine_version = lookup(var.option_group_params, "major_engine_version", null)
  options              = lookup(var.option_group_params, "options", null)
  pjprefix             = var.pjprefix
}

module "db_subnet_group" {
  count = var.subnet_group_params == null ? 0 : 1

  source     = "./subnet_group"
  name       = lookup(var.subnet_group_params, "name", null)
  subnet_ids = lookup(var.subnet_group_params, "subnet_ids", null)
  pjprefix   = var.pjprefix
}

module "aurora_cluster" {
  count                           = var.aurora_cluster_params == null ? 0 : 1
  source                          = "./cluster"
  pjprefix                        = var.pjprefix
  cluster_identifier              = var.aurora_cluster_identifier
  engine                          = lookup(var.aurora_cluster_params, "engine", "")
  engine_version                  = lookup(var.aurora_cluster_params, "engine_version", "")
  engine_mode                     = lookup(var.aurora_cluster_params, "engine_mode", "")
  db_security_group_ids           = var.aurora_security_group_ids
  db_subnet_group_name            = var.subnet_group_params == null ? null : module.db_subnet_group[0].name
  db_cluster_parameter_group_name = var.parameter_group_params == null ? null : module.db_parameter_group[0].name
  db_port                         = lookup(var.aurora_cluster_params, "db_port", null)
  db_name                         = lookup(var.aurora_cluster_params, "db_name", "")
  db_master_user_name             = lookup(var.aurora_cluster_params, "db_master_user_name", "")
  db_master_user_password         = lookup(var.aurora_cluster_params, "db_master_user_password", "")
  backup_retention_period         = lookup(var.aurora_cluster_params, "backup_retention_period")
  iam_roles                       = lookup(var.aurora_cluster_params, "iam_roles", null)
  preferred_backup_window         = lookup(var.aurora_cluster_params, "preferred_backup_window", null)
  preferred_maintenance_window    = lookup(var.aurora_cluster_params, "preferred_maintenance_window", null)
  apply_immediately               = lookup(var.aurora_cluster_params, "apply_immediately", true)
  backtrack_window                = lookup(var.aurora_cluster_params, "backtrack_window", null)
  aurora_instance_num             = lookup(var.aurora_cluster_params, "aurora_instance_num", 0)
  instance_class                  = lookup(var.aurora_cluster_params, "instance_class", null)
}
