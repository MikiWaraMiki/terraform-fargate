variable "pjprefix" {
  type    = string
  default = ""
}
variable "name" {
  type    = string
  default = ""
}
variable "retention_in_days" {
  type    = number
  default = 30
}

resource "aws_cloudwatch_log_group" "ecs_logging" {
  name              = (var.name == "" || var.name == null) ? "/ecs/${var.pjprefix}" : var.name
  retention_in_days = var.retention_in_days

  tags = {
    PJPrefix = var.pjprefix
    Name     = "/ecs/${var.pjprefix}"
  }
}


output "arn" {
  value = aws_cloudwatch_log_group.ecs_logging.arn
}
