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
variable "allow_rds_ingress_ips" {
  type    = list(string)
  default = []
}
variable "allow_elastic_cache_ips" {
  type    = list(string)
  default = []
}


module "alb_sg" {
  source = "./alb"

  vpc_id            = "${var.vpc_id}"
  pjprefix          = "${var.pjprefix}"
  allow_ingress_ips = "${var.allow_alb_ingress_ips}"
}

module "web_sg" {
  source = "./web"

  vpc_id    = "${var.vpc_id}"
  pjprefix  = "${var.pjprefix}"
  alb_sg_id = "${module.alb_sg.sg_id}"
}

module "rds_sg" {
  source                = "./rds"
  vpc_id                = "${var.vpc_id}"
  pjprefix              = "${var.pjprefix}"
  web_sg_id             = "${module.web_sg.sg_id}"
  allow_rds_ingress_ips = "${var.allow_rds_ingress_ips}"
}

module "elastic_cache_sg" {
  source                  = "./elasticcache"
  vpc_id                  = "${var.vpc_id}"
  pjprefix                = "${var.pjprefix}"
  web_sg_id               = "${module.web_sg.sg_id}"
  allow_elastic_cache_ips = "${var.allow_elastic_cache_ips}"
}
