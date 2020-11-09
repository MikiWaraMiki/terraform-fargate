variable "pjprefix" {
  type    = string
  default = ""
}
variable "cluster_identifier" {
  type    = string
  default = ""
}
variable "engine" {
  type    = string
  default = ""
}
variable "engine_mode" {
  type    = string
  default = ""
}
variable "engine_version" {
  type    = string
  default = ""
}
variable "db_security_group_ids" {
  type    = list(string)
  default = []
}
variable "db_subnet_group_name" {
  type    = string
  default = ""
}
variable "db_cluster_parameter_group_name" {
  type    = string
  default = ""
}
variable "db_port" {
  type    = number
  default = null
}
variable "db_name" {
  type    = string
  default = ""
}
variable "db_master_user_name" {
  type    = string
  default = ""
}
variable "db_master_user_password" {
  type    = string
  default = ""
}
variable "backup_retention_period" {
  type    = number
  default = 1
}
variable "preferred_backup_window" {
  type    = string
  default = "19:00-20:00"
}
variable "preferred_maintenance_window" {
  type    = string
  default = "20:00-21:00"
}
variable "apply_immediately" {
  type    = bool
  default = true
}
variable "backtrack_window" {
  type    = number
  default = 259200 # 72 hour
}
variable "iam_roles" {
  type    = list(string)
  default = []
}
variable "aurora_instance_num" {
  type    = number
  default = 1
}
variable "instance_class" {
  type    = string
  default = ""
}
# Local Value
locals {
  snapshot_prefix    = "${var.pjprefix}-snapshot"
  cluster_identifier = (var.cluster_identifier == "" || var.cluster_identifier == null) ? "aurora-cluster-${var.pjprefix}" : var.cluster_identifier
}
# 乱数生成用
resource "random_id" "snapshot_identifier" {
  keepers = {
    id = var.cluster_identifier
  }
  byte_length = 4
}
resource "aws_rds_cluster" "aurora_default" {
  cluster_identifier = var.cluster_identifier
  engine             = var.engine
  engine_mode        = var.engine_mode
  engine_version     = var.engine_version
  # paramter group
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name
  # subnetgroup
  db_subnet_group_name = var.db_subnet_group_name
  # security group
  vpc_security_group_ids = var.db_security_group_ids
  # Database Settings
  database_name   = var.db_name
  master_password = var.db_master_user_password
  master_username = var.db_master_user_name
  port            = var.db_port
  # snapshot
  final_snapshot_identifier = "${local.snapshot_prefix}-${element(concat(random_id.snapshot_identifier.*.hex, [""]), 0)}"
  backup_retention_period   = var.backup_retention_period
  # maintenance
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  apply_immediately            = var.apply_immediately
  backtrack_window             = var.backtrack_window
  copy_tags_to_snapshot        = true
  # iam role
  iam_roles = var.iam_roles

  tags = {
    Name = "aurora-cluster-${var.pjprefix}"
  }
}

resource "aws_rds_cluster_instance" "aurora_default" {
  count              = var.aurora_instance_num
  identifier         = "aurora-cluster-${var.pjprefix}"
  cluster_identifier = aws_rds_cluster.aurora_default.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.aurora_default.engine
  engine_version     = aws_rds_cluster.aurora_default.engine_version
}

output "cluster_params_id" {
  description = "Aurora Cluster Group Id."
  value       = aws_rds_cluster.aurora_default.id
}
output "id_list_aurora_instance" {
  description = "Aurora Cluster Instaces ids"
  value       = aws_rds_cluster_instance.aurora_default.*.id
}
