variable "zone_id" {
  type    = string
  default = ""
}
variable "name" {
  type    = string
  default = ""
}
variable "record_type" {
  type    = string
  default = ""
}
variable "ttl" {
  description = "required if record is non alias."
  type        = number
  default     = 30
}
variable "alias_config" {
  description = "if added alias record. this setting is required"
  type = object({
    name                   = string,
    zone_id                = string,
    evaluate_target_health = bool
  })
  default = null
}
variable "records" {
  type    = list(string)
  default = []
}

#################################
# Create Record
#################################
# 非ALIASレコード作成用途
resource "aws_route53_record" "non_alias_record" {
  #count   = "${var.is_alias_record ? 0 : 1}"
  zone_id = "${var.zone_id}"
  name    = "${var.name}"
  type    = "${var.record_type}"
  # For Non Alias Record
  ttl     = var.ttl != null ? var.ttl : null
  records = var.records != null ? var.records : null
  #For ALIAS Record
  dynamic "alias" {
    for_each = var.alias_config != null ? [var.alias_config] : []

    content {
      name                   = lookup(alias.value, "name", null)
      zone_id                = lookup(alias.value, "zone_id", null)
      evaluate_target_health = lookup(alias.value, "evaluate_target_health", null)
    }
  }
}

# # ALIASレコード作成用途
# resource "aws_route53_record" "alias_record" {
#   count   = "${var.is_alias_record ? 1 : 0}"
#   zone_id = "${var.zone_id}"
#   name    = "${var.name}"
#   type    = "${var.record_type}"

#   alias {
#     name                   = lookup(var.alias_config, "name", null)
#     zone_id                = lookup(var.alias_config, "zone_id", null)
#     evaluate_target_health = lookup(var.alias_config, "evaluate_target_health", false)
#   }
# }
