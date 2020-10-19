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
  type    = string
  default = ""
}
variable "alias" {
  type = list(object({
    name                   = string,
    zone_id                = string,
    evaluate_target_health = bool
  }))
  default = []
}
variable "records" {
  type    = list(string)
  default = []
}

#################################
# Create Record
#################################
resource "aws_route53_record" "main_route" {
  zone_id = "${var.zone_id}"
  name    = "${var.name}"
  type    = "${var.record_type}"

  dynamic "alias" {
    for_each = "${var.alias}"

    content {
      name                   = lookup(alias.value, "name", null)
      zone_id                = lookup(alias.value, "zone_id", null)
      evaluate_target_health = lookup(alias.value, "evaluate_target_health", false)
    }
  }

  records = length(records) == 0 ? null : var.records
}