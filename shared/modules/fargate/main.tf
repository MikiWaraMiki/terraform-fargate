variable "pjprefix" {
  type    = string
  default = ""
}
# ECS Task Definition
variable "task_definition_arn" {
  type    = string
  default = ""
}
variable "task_definition_params" {
  type    = map
  default = null
}
# ECS Cluster
variable "ecs_cluster_arn" {
  type    = string
  default = ""
}
# ECS Service
variable "ecs_service_params" {
  type    = map
  default = null
}
variable "security_group_ids" {
  type    = list(string)
  default = []
}
variable "subnet_ids" {
  type    = list(string)
  default = []
}
variable "target_group_arn" {
  type    = string
  default = ""
}
variable "alb_attach_container_name" {
  type    = string
  default = ""
}
variable "alb_attach_container_port" {
  type    = number
  default = 80
}
# Logging
variable "ecs_logging_params" {
  type    = map
  default = null
}

module "cluster" {
  count = var.ecs_cluster_arn == "" ? 1 : 0

  source   = "./cluster"
  pjprefix = var.pjprefix
}

module "task_definition" {
  count = var.task_definition_arn == "" ? 1 : 0

  source                = "./task_definition"
  family                = var.task_definition_params.family
  container_definitions = var.task_definition_params.container_definitions
  cpu                   = var.task_definition_params.cpu
  memory                = var.task_definition_params.memory
  pjprefix              = var.pjprefix
  execution_role_arn    = lookup(var.task_definition_params, "execution_role_arn", null)
}


module "ecs_service" {
  source = "./service"

  pjprefix                          = var.pjprefix
  cluster_arn                       = var.ecs_cluster_arn == "" ? module.cluster[0].arn : var.ecs_cluster_arn
  task_definition_arn               = var.task_definition_arn == "" ? module.task_definition[0].arn : var.task_definition_arn
  desired_count                     = var.ecs_service_params.desired_count
  platform_version                  = var.ecs_service_params.platform_version
  health_check_grace_period_seconds = var.ecs_service_params.health_check_grace_period_seconds
  assign_public_ip                  = var.ecs_service_params.assign_public_ip
  security_group_ids                = var.security_group_ids
  subnet_ids                        = var.subnet_ids
  target_group_arn                  = var.target_group_arn
  container_name                    = var.alb_attach_container_name
  container_port                    = var.alb_attach_container_port
}

module "ecs_logging" {
  source = "./logging"

  pjprefix          = var.pjprefix
  name              = var.ecs_logging_params != null ? lookup(var.ecs_logging_params, "name", null) : null
  retention_in_days = var.ecs_logging_params != null ? lookup(var.ecs_logging_params, "retention_in_days", null) : null
}
