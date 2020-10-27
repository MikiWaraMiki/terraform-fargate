variable "parameter_group_params" {
  type    = any
  default = null
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
  pjprefix   = var.pjprefix
}
