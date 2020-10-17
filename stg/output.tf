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
