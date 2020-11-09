output "parameter_group_name" {
  value = var.parameter_group_params == null ? "not created" : module.db_parameter_group[0].name
}
output "option_group_name" {
  value = var.option_group_params == null ? "not created" : module.db_option_group[0].name
}
output "subnet_group_name" {
  value = var.subnet_group_params == null ? "not created" : module.db_subnet_group[0].name
}
