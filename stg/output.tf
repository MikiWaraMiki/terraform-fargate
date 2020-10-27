output "vpc_id" {
  description = "vpc id"
  value       = "${module.network.vpc_id}"
}
output "public_subnet_ids" {
  description = "subnet ids for alb"
  value       = "${module.network.public_subnet_ids}"
}
output "web_subnet_ids" {
  description = "subnet ids for web server"
  value       = "${module.network.web_subnet_ids}"
}

output "database_subnet_ids" {
  description = "subent ids for database"
  value       = "${module.network.database_subnet_ids}"
}

output "elastic_cache_subnet_ids" {
  description = "subnet ids for elastic cache"
  value       = "${module.network.elastic_cache_subnet_ids}"
}

output "alb_sg_id" {
  description = "security group id of alb "
  value       = "${module.security_group.alb_sg_id}"
}

output "web_sg_id" {
  description = "web security group id"
  value       = "${module.security_group.web_sg_id}"
}

output "rds_sg_id" {
  description = "rds security group id"
  value       = "${module.security_group.rds_sg_id}"
}

output "elastic_cache_sg_id" {
  description = "elastic cache security group id"
  value       = "${module.security_group.elastic_cache_sg_id}"
}

# ALB
output "alb_id" {
  description = "alb ids"
  value       = "${module.alb.alb_id}"
}
output "alb_arn" {
  description = "alb arn"
  value       = "${module.alb.alb_arn}"
}
output "alb_dns_name" {
  description = "alb dns name"
  value       = "${module.alb.alb_dns_name}"
}

# ElasticCache
output "ec_parameter_group_id" {
  description = "ElastiCache parameter group id"
  value       = module.elastic_cache.parameter_group_id
}
output "ec_parameter_group_name" {
  description = "ElastiCache parameter group name"
  value       = module.elastic_cache.parameter_group_name
}
output "ec_subnet_group_name" {
  description = "ElasticCache subnet group name"
  value       = module.elastic_cache.subnet_group_name
}

# Fargate
output "ecs_cluster_arn" {
  description = "Fargate Cluster ARN. If Cluster created, this is shown"
  value       = module.fargate.cluster_arn
}
output "ecs_task_definition_arn" {
  description = "Fargate Task Definition Arn. If created, this is shown"
  value       = module.fargate.task_definition_arn
}

output "ecs_iam_role_arn" {
  description = "Fargate iam role arn."
  value       = module.fargate_iam.iam_role_arn
}
output "ecs_iam_role_name" {
  description = "Fargate iam role name."
  value       = module.fargate_iam.iam_role_name
}
output "ecs_service_arn" {
  description = "Fargate Service arn."
  value       = module.fargate.service_arn
}
output "ecs_service_name" {
  description = "Fargate Service name"
  value       = module.fargate.service_name
}

# Aurora
output "db_parameter_group_name" {
  description = "Aurora Parameter Group name"
  value       = module.aurora.parameter_group_name
}
