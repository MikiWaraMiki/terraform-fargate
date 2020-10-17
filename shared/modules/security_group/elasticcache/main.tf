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
variable "allow_elastic_cache_ips" {
  type    = list(string)
  default = []
}
variable "elastic_cache_port" {
  type = number
  # default is memcached
  default = 11211
}

##########################
# Create Security Group
##########################
resource "aws_security_group" "elastic_cache_sg" {
  name        = "elastic-cache-sg-${var.pjprefix}"
  description = "ElasticCache Security Group. Allow via websg and optional"
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name     = "elastic-cache-sg-${var.pjprefix}"
    PJPrefix = "${var.pjprefix}"
  }
}
# Ingress Rules
resource "aws_security_group_rule" "allow_via_websg" {
  type                     = "ingress"
  from_port                = "${var.elastic_cache_port}"
  to_port                  = "${var.elastic_cache_port}"
  protocol                 = "tcp"
  source_security_group_id = "${var.web_sg_id}"
  security_group_id        = "${aws_security_group.elastic_cache_sg.id}"
}
resource "aws_security_group_rule" "allow_via_ip" {
  count             = "${length(var.allow_elastic_cache_ips)}"
  type              = "ingress"
  from_port         = "${var.elastic_cache_port}"
  to_port           = "${var.elastic_cache_port}"
  protocol          = "tcp"
  cidr_blocks       = "${var.allow_elastic_cache_ips}"
  security_group_id = "${aws_security_group.elastic_cache_sg.id}"
}

# Egress Rules
resource "aws_security_group_rule" "allow_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elastic_cache_sg.id}"
}


#########################
# Output
#########################
output "sg_id" {
  description = "RDS Security Group id"
  value       = "${aws_security_group.elastic_cache_sg.id}"
}
