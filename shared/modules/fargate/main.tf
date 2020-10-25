variable "pjprefix" {
  type    = string
  default = ""
}
variable "task_definition_arn" {
  type    = string
  default = ""
}
variable "task_definition_params" {
  type    = map
  default = null
}
variable "ecs_cluster_arn" {
  type    = string
  default = ""
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
}


output "cluster_arn" {
  value = var.ecs_cluster_arn == "" ? "not created" : module.cluster[0].arn
}

output "task_definition_arn" {
  value = var.task_definition_arn == "" ? "not created" : module.task_definition[0].arn
}
