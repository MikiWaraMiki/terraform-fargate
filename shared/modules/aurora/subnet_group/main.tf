variable "name" {
  type    = string
  default = ""
}
variable "subnet_ids" {
  type    = list(string)
  default = []
}
variable "pjprefix" {
  type    = string
  default = ""
}

locals {
  sg_name = (var.name == "" || var.name == null) ? "rds-subnet-group-${var.pjprefix}" : var.name
}


resource "aws_db_subnet_group" "subnet_group" {
  name       = local.sg_name
  subnet_ids = var.subnet_ids

  tags = {
    Name     = local.sg_name
    PJPrefix = var.pjprefix
  }
}


output "id" {
  value = aws_db_subnet_group.subnet_group.id
}

output "arn" {
  value = aws_db_subnet_group.subnet_group.arn
}
output "name" {
  value = aws_db_subnet_group.subnet_group.name
}
