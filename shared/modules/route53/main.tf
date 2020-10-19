# 新規にホストゾーンを作成する場合のみ指定
variable "is_create_host_zone" {
  description = "If you new host zone. this value must be true."
  type    = bool
  default = false
}
variable "domain_name" {
  type    = string
  default = ""
  description = "If you create new host zone. you must input this args"
}


variable "zone_name" {
  type    = string
  default = ""
}
variable "pjprefix" {
  type    = string
  default = ""
}

# var info
variable "route_list" {
  type = list(object({
    name = string
    record_type = string
    ttl = string
    alias = list(object())
    records = []
    evaluate_target_health = bool
  }))
  default = []
}

###################################
# Create Host Zone
# 新規に作成する場合のみ利用する
###################################
resource "aws_route53_zone" "main_zone" {
  count = var.is_create_host_zone ? 1 : 0
  name  = "${var.domain_name}"

  tags {
    Name     = "${var.zone_name}"
    PJPrefix = "${var.pjprefix}"
  }
}


###################################
# Route 情報の登録
###################################
# 既存のホストゾーンを利用する場合は、dataから取得する
data "aws_route53_zone" "selected_zone" {
  count = var.is_create_host_zone ? 0 : 1
  name = var.zone_name
}

module "route53_record" {
  count = length(route_list)
  source = "./record"

  # variable
  zone_id = var.is_create_host_zone ? aws_route53_zone.main_zone.id : data.aws_route53_zone.selected_zone.id
  name = lookup(element(var.route_list, count.index), "name", null)
  ttl = lookup(element(var.route_list, count.index), "ttl" , null)
  alias = lookup(element(var.route_list, count.index), "alias", null)
  records = lookup(element(var.route_list, count.index), "routes", null)
}
