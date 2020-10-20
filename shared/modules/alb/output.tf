output "alb_id" {
  description = "alb ids"
  value       = "${aws_lb.main_alb.id}"
}
output "alb_arn" {
  description = "alb arn"
  value       = "${aws_lb.main_alb.arn}"
}
output "alb_dns_name" {
  description = "alb dns name"
  value       = "${aws_lb.main_alb.dns_name}"
}
output "alb_zone_id" {
  description = "alb zone id"
  value = "${aws_lb.main_alb.zone_id}"
}