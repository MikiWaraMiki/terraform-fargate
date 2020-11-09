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
variable "is_cluster" {
  type    = bool
  default = true
}

locals {
  pg_name = (var.name == "" || var.name == null) ? "db-parameter-group-${var.pjprefix}" : var.name
}

resource "aws_db_parameter_group" "db_pg" {
  count  = var.is_cluster ? 0 : 1
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
resource "aws_rds_cluster_parameter_group" "db_cluster_pg" {
  count  = var.is_cluster ? 1 : 0
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
  value = var.is_cluster ? aws_rds_cluster_parameter_group.db_cluster_pg[0].id : aws_db_parameter_group.db_pg[0].id
}
output "name" {
  value = var.is_cluster ? aws_rds_cluster_parameter_group.db_cluster_pg[0].name : aws_db_parameter_group.db_pg[0].name
}
output "arn" {
  value = var.is_cluster ? aws_rds_cluster_parameter_group.db_cluster_pg[0].arn : aws_db_parameter_group.db_pg[0].arn
}
