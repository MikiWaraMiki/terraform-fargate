output "cluster_arn" {
  value = var.ecs_cluster_arn == "" ? module.cluster[0].arn : var.ecs_cluster_arn
}

output "task_definition_arn" {
  value = var.task_definition_arn == "" ? module.task_definition[0].arn : var.task_definition_arn
}
output "service_arn" {
  value = module.ecs_service.arn
}
output "service_name" {
  value = module.ecs_service.name
}
