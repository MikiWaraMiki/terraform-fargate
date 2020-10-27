variable "parameters" {
  type    = list(map(any))
  default = []
}
variable "family" {
  type    = string
  default = ""
}
variable "name" {
  type    = string
  default = ""
}
variable "pjprefix" {
  type    = string
  default = ""
}

locals {
  pg_name = (var.name == "" || var.name == null) ? "db-parameter-group-${var.pjprefix}" : var.name
}

resource "aws_db_parameter_group" "db_pg" {
  name   = local.pg_name
  family = var.family
  dynamic "parameter" {
    for_each = var.parameters

    content {
      name  = lookup(parameter.value, "name", null)
      value = lookup(parameter.value, "value", null)
    }
  }
  tags = {
    PJPrefix = var.pjprefix
  }
}

output "id" {
  value = aws_db_parameter_group.db_pg.id
}
output "name" {
  value = aws_db_parameter_group.db_pg.name
}
output "arn" {
  value = aws_db_parameter_group.db_pg.arn
}
