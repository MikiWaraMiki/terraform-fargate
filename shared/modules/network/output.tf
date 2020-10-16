output "vpc_id" {
  description = "The ID of the vpc"
  value       = "${module.vpc.vpc_id}"
}

output "web_subnet_ids" {
  description = "subnet ids for web server"
  value       = "${module.subnet.web_subnet_ids}"
}

output "database_subnet_ids" {
  description = "subent ids for database"
  value       = "${module.subnet.database_subnet_ids}"
}

output "elastic_cache_subnet_ids" {
  description = "subnet ids for elastic cache"
  value       = "${module.subnet.elastic_cache_subnet_ids}"
}
