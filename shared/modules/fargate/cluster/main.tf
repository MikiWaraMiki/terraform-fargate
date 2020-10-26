variable "pjprefix" {
  type    = string
  default = ""
}

resource "aws_ecs_cluster" "main" {
  name = "ecs-cluster-${var.pjprefix}"

  tags = {
    Name     = "ecs-cluster-${var.pjprefix}"
    PJPrefix = var.pjprefix
  }
}

output "arn" {
  value = aws_ecs_cluster.main.arn
}
