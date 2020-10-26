variable "container_definitions" {
  type    = string
  default = ""
}
variable "execution_role_arn" {
  type    = string
  default = ""
}
variable "family" {
  type    = string
  default = ""
}
variable "cpu" {
  type    = string
  default = "256"
}
variable "memory" {
  type    = string
  default = "512"
}
variable "pjprefix" {
  type    = string
  default = ""
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.family
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = var.container_definitions
  # roleはアタッチしない場合もあるため任意
  execution_role_arn = (var.execution_role_arn == "" || var.execution_role_arn == null) ? null : var.execution_role_arn

  tags = {
    Name     = "task-definition-${var.pjprefix}"
    PJPrefix = var.pjprefix
  }
}


output "arn" {
  value = aws_ecs_task_definition.main.arn
}
