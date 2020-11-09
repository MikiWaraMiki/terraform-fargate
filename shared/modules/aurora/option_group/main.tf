# See https://qiita.com/fjisdahgaiuerua/items/8be3a3ad049d98772e5d
variable "name" {
  type    = string
  default = ""
}
variable "engine_name" {
  type    = string
  default = ""
}
variable "major_engine_version" {
  type    = string
  default = ""
}
variable "options" {
  type = list(object(
    {
      option_name = string
    }
  ))
  default = []
}
variable "pjprefix" {
  type    = string
  default = ""
}

locals {
  op_name = (var.name == "" || var.name == null) ? "db-option-group-${var.pjprefix}" : var.name

}
resource "aws_db_option_group" "op_group" {
  name                 = local.op_name
  engine_name          = var.engine_name
  major_engine_version = var.major_engine_version

  dynamic "option" {
    for_each = var.options

    content {
      option_name = lookup(option.value, "option_name", null)
    }
  }

  tags = {
    PJPrefix = var.pjprefix
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "name" {
  value = aws_db_option_group.op_group.name
}
output "arn" {
  value = aws_db_option_group.op_group.arn
}
