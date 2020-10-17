######################
# Variable
######################
variable "vpc_id" {
  type    = string
  default = ""
}
variable "subnet_ids" {
  type    = list(string)
  default = []
}
variable "ingress_black_list" {
  description = "Ingress Black List"
  type = list(object({
    protocol   = string,
    rule_no    = number,
    cidr_block = string,
    from_port  = number,
    to_port    = number
  }))
  default = []
}
variable "egress_black_list" {
  description = "Egress Black List"
  type = list(object({
    protocol   = string,
    rule_no    = number,
    cidr_block = string,
    from_port  = number,
    to_port    = number
  }))
  default = []
}
variable "pjprefix" {
  type    = string
  default = ""
}

########################################
# Create Network ACL
########################################
resource "aws_network_acl" "main_acl" {
  vpc_id     = "${var.vpc_id}"
  subnet_ids = "${var.subnet_ids}"
  tags = {
    Name     = "acl-${var.pjprefix}"
    PJPrefix = "${var.pjprefix}"
  }
}
# Default White list
resource "aws_network_acl_rule" "ingress_allow_rule" {
  network_acl_id = "${aws_network_acl.main_acl.id}"
  rule_number    = 100
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}
resource "aws_network_acl_rule" "egress_allow_rule" {
  network_acl_id = "${aws_network_acl.main_acl.id}"
  rule_number    = 100
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}
# Black list
resource "aws_network_acl_rule" "ingress_deny_rule" {
  count          = length(var.ingress_black_list)
  rule_number    = lookup(element(var.ingress_black_list, count.index), "rule_no")
  egress         = false
  protocol       = lookup(element(var.ingress_black_list, count.index), "protocol")
  rule_action    = "deny"
  cidr_block     = lookup(element(var.ingress_black_list, count.index), "cidr_block")
  from_port      = lookup(element(var.ingress_black_list, count.index), "from_port")
  to_port        = lookup(element(var.ingress_black_list, count.index), "to_port")
  network_acl_id = "${aws_network_acl.main_acl.id}"
}
resource "aws_network_acl_rule" "egress_deny_rule" {
  count          = length(var.egress_black_list)
  rule_number    = lookup(element(var.egress_black_list, count.index), "rule_no")
  egress         = true
  protocol       = lookup(element(var.egress_black_list, count.index), "protocol")
  rule_action    = "deny"
  cidr_block     = lookup(element(var.egress_black_list, count.index), "cidr_block")
  from_port      = lookup(element(var.egress_black_list, count.index), "from_port")
  to_port        = lookup(element(var.egress_black_list, count.index), "to_port")
  network_acl_id = "${aws_network_acl.main_acl.id}"
}

#####################
# Output
#####################
output "acl_id" {
  description = "acl id"
  value       = "${aws_network_acl.main_acl.id}"
}
