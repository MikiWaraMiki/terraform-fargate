variable "vpc_id" {
  type    = string
  default = ""
}
variable "pjprefix" {
  type    = string
  default = ""
}
variable "web_sg_id" {
  type    = string
  default = ""
}
variable "allow_mysql_ingress_ips" {
  type    = list(string)
  default = []
}
variable "rds_port" {
  type    = number
  default = 3306
}

##########################
# Create Security Group
##########################
resource "aws_security_group" "rds_security_group" {
  name        = "security-group"
  description = "RDS Security Group. Allow mysql via websg, and optional."
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name     = "db-sg-${var.pjprefix}"
    PJPrefix = "${var.pjprefix}"
  }
}

# Ingress Rules
resource "aws_security_group_rule" "allow_mysql_via_websg" {
  type                     = "ingress"
  from_port                = "${var.rds_port}"
  to_port                  = "${var.rds_port}"
  protocol                 = "tcp"
  source_security_group_id = "${var.web_sg_id}"
  security_group_id        = "${aws_security_group.rds_security_group.id}"
}
resource "aws_security_group_rule" "allow_mysql_via_allow_ip" {
  count             = "${length(var.allow_mysql_ingress_ips)}"
  type              = "ingress"
  from_port         = "${var.rds_port}"
  to_port           = "${var.rds_port}"
  protocol          = "tcp"
  cidr_blocks       = "${var.allow_mysql_ingress_ips}"
  security_group_id = "${aws_security_group.rds_security_group.id}"
}

# Egress Rules
resource "aws_security_group_rule" "allow_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.rds_security_group.id}"
}


#########################
# Output
#########################
output "sg_id" {
  description = "RDS Security Group id"
  value       = "${aws_security_group.rds_security_group.id}"
}
