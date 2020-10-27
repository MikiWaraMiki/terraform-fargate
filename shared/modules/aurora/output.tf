output "parameter_group_name" {
  value = var.parameter_group_params == null ? "not created" : module.db_parameter_group[0].name
}
