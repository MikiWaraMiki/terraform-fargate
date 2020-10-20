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
variable "is_create_subnet_group" {
  type    = bool
  default = false
}
variable "subnet_ids" {
  type    = list(string)
  default = []
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

output "parameter_group_id" {
  value = var.is_create_parameter_group ? "${module.parameter_group[0].id}" : ""
}
output "parameter_group_name" {
  value = var.is_create_parameter_group ? "${module.parameter_group[0].name}" : ""
}
output "subnet_group_name" {
  value = var.is_create_subnet_group ? module.subnet_group[0].name : ""
}
