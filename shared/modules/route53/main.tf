# 新規にホストゾーンを作成する場合のみ指定
variable "is_create_host_zone" {
  type    = bool
  default = false
}
variable "domain_name" {
  type    = string
  default = ""
}


variable "zone_name" {
  type    = string
  default = ""
}
variable "pjprefix" {
  type    = string
  default = ""
}
variable "route_info" {
  type = list
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
