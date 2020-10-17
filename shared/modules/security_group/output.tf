output "alb_sg_id" {
  description = "ALB Security Group id"
  value       = "${module.alb_sg.sg_id}"
}
output "web_sg_id" {
  description = "Web Security Group id"
  value       = "${module.web_sg.sg_id}"
}
output "rds_sg_id" {
  description = "RDS Security Group id"
  value       = "${module.rds_sg.sg_id}"
}
output "elastic_cache_sg_id" {
  description = "Elastic Cache Security Group id"
  value       = "${module.elastic_cache_sg.sg_id}"
}
