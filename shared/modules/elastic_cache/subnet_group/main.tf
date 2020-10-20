variable "subnet_ids" {
  type    = list(string)
  default = []
}
variable "name" {
  type    = string
  default = ""
}
resource "aws_elasticache_subnet_group" "main_group" {
  description = "elastic cache subnet group for ${var.name} "
  name        = var.name
  subnet_ids  = var.subnet_ids
}

output "name" {
  value = aws_elasticache_subnet_group.main_group.name
}
