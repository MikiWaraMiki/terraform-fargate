output "alb_sg_id" {
  description = "ALB Security Group id"
  value       = "${module.alb_sg.sg_id}"
}
output "web_sg_id" {
  description = "Web Security Group id"
  value       = "${module.web_sg.sg_id}"
}
