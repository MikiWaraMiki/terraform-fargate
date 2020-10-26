variable "pjprefix" {
  type    = string
  default = ""
}
variable "cluster_arn" {
  type    = string
  default = ""
}
variable "task_definition_arn" {
  type    = string
  default = ""
}
variable "desired_count" {
  description = "prodution must be more then 2"
  type        = number
  default     = 1
}
variable "platform_version" {
  description = "See https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/platform_versions.html"
  type        = string
  default     = "1.4.0"
}
variable "health_check_grace_period_seconds" {
  type    = number
  default = 60
}
variable "assign_public_ip" {
  type    = bool
  default = false
}
variable "security_group_ids" {
  type    = list(string)
  default = []
}
variable "subnet_ids" {
  type    = list(string)
  default = []
}
variable "target_group_arn" {
  type    = string
  default = ""
}
# ALBに紐付けるコンテナ名(task definitionを参照する.基本的にはnginx)
# task defintionのname, portMappings.containerPortと合わせる必要がある
variable "container_name" {
  type    = string
  default = "nginx"
}
variable "container_port" {
  type    = number
  default = 80
}

resource "aws_ecs_service" "main" {
  name                              = "ecs-service-${var.pjprefix}"
  cluster                           = var.cluster_arn
  task_definition                   = var.task_definition_arn
  desired_count                     = var.desired_count
  launch_type                       = "FARGATE"
  platform_version                  = var.platform_version
  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  network_configuration {
    assign_public_ip = var.assign_public_ip
    security_groups  = var.security_group_ids
    subnets          = var.subnet_ids
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }

  tags = {
    Name     = "ecs-service-${var.pjprefix}"
    PJPrefix = var.pjprefix
  }
}

output "arn" {
  value = aws_ecs_service.main.id
}
output "name" {
  value = aws_ecs_service.main.name
}
