variable "vpc_id" {
  type    = string
  default = ""
}
variable "pjprefix" {
  type    = string
  default = ""
}

variable "alb_sg_id" {
  type    = string
  default = ""
}


##########################
# Create Security Group
##########################
resource "aws_security_group" "web_security_group" {
  name        = "web-sg-${var.pjprefix}"
  description = "Web Security Group. Allow http via alb, and optional."
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name     = "web-sg-${var.pjprefix}"
    PJPrefix = "${var.pjprefix}"
  }
}
# Ingress Rules
resource "aws_security_group_rule" "allow_http_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${var.alb_sg_id}"
  security_group_id        = "${aws_security_group.web_security_group.id}"
}
# Egress Rules
resource "aws_security_group_rule" "allow_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web_security_group.id}"
}


#########################
# Output
#########################
output "sg_id" {
  description = "Web Security Group id"
  value       = "${aws_security_group.web_security_group.id}"
}
