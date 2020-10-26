variable "vpc_id" {
  type    = string
  default = ""
}
variable "pjprefix" {
  type    = string
  default = ""
}
variable "name" {
  type    = string
  default = ""
}
variable "description" {
  type    = string
  default = ""
}
variable "ingress_rule_list" {
  type = list(map(
    {
      description       = string
      to_port           = number
      from_port         = number
      protocol          = string
      security_group_id = string
      cidr_blocks       = list(string)
    }
  ))
  default = []
}
variable "egress_rule_list" {
  type = list(map(
    {
      description       = string
      to_port           = number
      from_port         = number
      protocol          = string
      security_group_id = string
      cidr_blocks       = list(string)
    }
  ))
}

resource "aws_security_group" "sg_main" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = {
    Name     = var.name
    PJPrefix = var.pjprefix
  }
}
resource "aws_security_group_rule" "ingress_rules" {
  count = length(var.ingress_rule_list)

  description              = lookup(element(var.ingress_rule_list, count.index), "description", "")
  type                     = "ingress"
  protocol                 = lookup(element(var.ingress_rule_list, count.index), "protocol", "")
  source_security_group_id = lookup(element(var.ingress_rule_list, count.index), "security_group_id", null)
  cidr_blocks              = lookup(element(var.ingress_rule_list, count.index), "cidr_block", null)
  security_group_id        = aws_security_group.sg_main.id
}

resource "aws_security_group_rule" "egress_rules" {
  description              = lookup(element(var.egress_rule_list, count.index), "description", "")
  type                     = "egress"
  protocol                 = lookup(element(var.egress_rule_list, count.index), "protocol", "")
  source_security_group_id = lookup(element(var.egress_rule_list, count.index), "security_group_id", null)
  cidr_block               = lookup(element(var.egress_rule_list, count.index), "cidr_block", null)
  security_group_id        = aws_security_group.sg_main.id
}
