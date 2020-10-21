variable "repl_id" {
  type    = string
  default = ""
}
variable "engine" {
  type    = string
  default = ""
}
variable "engine_version" {
  type    = string
  default = ""
}
variable "number_cache_clusters" {
  type    = number
  default = 2
}
variable "node_type" {
  type    = string
  default = ""
}
variable "snapshot_window" {
  description = "default is AM 0:00 - AM 1:10 JST"
  type        = string
  default     = "15:10-16:10"
}
variable "snapshot_retention_limit" {
  description = "snap shot store limit. default 5 days"
  type        = number
  default     = 5
}
variable "maintenance_window" {
  description = "maintenance window. default is sun AM 2:00 ~ AM:3:00"
  type        = string
  default     = "mon:19:00-mon:20:00"
}
variable "automatic_failover_enabled" {
  description = "if this value is true, cluster must be multi-az"
  type        = bool
  default     = false
}
variable "port" {
  type    = number
  default = 6379
}
variable "apply_immediately" {
  description = "if value is false, change settings is apply in main_tenance_window"
  type        = bool
  default     = false
}
variable "security_group_ids" {
  type    = list(string)
  default = []
}
variable "parameter_group_name" {
  type    = string
  default = ""
}
variable "subnet_group_name" {
  type    = string
  default = ""
}


resource "aws_elasticache_replication_group" "main_repl_group" {
  replication_group_id          = var.repl_id
  replication_group_description = "repl group for ${var.repl_id}"
  engine                        = var.engine
  engine_version                = var.engine_version
  number_cache_clusters         = var.number_cache_clusters
  node_type                     = var.node_type
  snapshot_window               = var.snapshot_window
  snapshot_retention_limit      = var.snapshot_retention_limit
  maintenance_window            = var.maintenance_window
  automatic_failover_enabled    = var.automatic_failover_enabled
  port                          = var.port
  apply_immediately             = var.apply_immediately
  security_group_ids            = var.security_group_ids
  parameter_group_name          = var.parameter_group_name
  subnet_group_name             = var.subnet_group_name
}

output "id" {
  value = aws_elasticache_replication_group.main_repl_group.id
}
