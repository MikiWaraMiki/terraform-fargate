variable "name" {
  type    = string
  default = ""
}
variable "family" {
  type    = string
  default = ""
}

variable "parameters" {
  type = list(object(
    {
      name  = string
      value = string
    }
  ))
  default = null
}

resource "aws_elasticache_parameter_group" "main_parameter_group" {
  description = "${var.name} elastic cache parameter group."
  name        = var.name
  family      = var.family

  dynamic "parameter" {
    for_each = var.parameters != null ? var.parameters : []
    content {
      name  = lookup(parameter.value, "name", null)
      value = lookup(parameter.value, "value", "")
    }
  }
}

output "id" {
  value = "${aws_elasticache_parameter_group.main_parameter_group.id}"
}
output "name" {
  value = "${aws_elasticache_parameter_group.main_parameter_group.name}"
}
