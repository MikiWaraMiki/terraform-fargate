variable "vpc_id" {
  type    = string
  default = ""
}
variable "pjprefix" {
  type    = string
  default = ""
}
variable "allow_alb_ingress_ips" {
  type    = list(string)
  default = []
}


module "alb_sg" {
  source = "./alb"

  vpc_id            = "${var.vpc_id}"
  pjprefix          = "${var.pjprefix}"
  allow_ingress_ips = "${var.allow_alb_ingress_ips}"
}
