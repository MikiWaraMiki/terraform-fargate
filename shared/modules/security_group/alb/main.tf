variable "vpc_id" {
  type    = string
  default = ""
}
variable "pjprefix" {
  type    = string
  default = ""
}
variable "allow_ingress_ips" {
  type    = list(string)
  default = []
}
variable "allow_ingress_ports" {
  type    = list(number)
  default = []
}

locals {
  allow_ingress_ips   = "${length(var.allow_ingress_ips) > 0 ? var.allow_ingress_ips : ["0.0.0.0/0"]}"
  allow_ingress_ports = "${length(var.allow_ingress_ports) > 0 ? concat(var.allow_ingress_ports, [80, 443]) : [80, 443]}"
}

#########################
# Create Security Group
#########################
resource "aws_security_group" "alb_security_group" {
  name        = "alb-sg-${var.pjprefix}"
  description = "ALB Security Group. Allow HTTP and HTTPS"
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name     = "alb-sg-${var.pjprefix}"
    PJPrefix = "${var.pjprefix}"
  }
}
# Ingress Rules
resource "aws_security_group_rule" "allow_ingress" {
  count             = "${length(local.allow_ingress_ports)}"
  type              = "ingress"
  from_port         = "${element(local.allow_ingress_ports, count.index)}"
  to_port           = "${element(local.allow_ingress_ports, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = "${local.allow_ingress_ips}"
  security_group_id = "${aws_security_group.alb_security_group.id}"
}
# Egress Rules
resource "aws_security_group_rule" "allow_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb_security_group.id}"
}

#########################
# Output
#########################
output "sg_id" {
  description = "ALB Security Group Id"
  value       = "${aws_security_group.alb_security_group.id}"
}
