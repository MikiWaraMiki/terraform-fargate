terraform {
  required_version = ">= 0.12.0"
  backend s3 {
  }
}
provider "aws" {
  region  = var.region
  profile = var.profile
}

module "network" {
  source                 = "../shared/modules/network/"
  pjprefix               = "${var.pjprefix}"
  vpc_cidr               = "${var.vpc_cidr}"
  public_subnets         = "${var.public_subnets}"
  web_subnets            = "${var.web_subnets}"
  database_subnets       = "${var.database_subnets}"
  elastic_cache_subnets  = "${var.elastic_cache_subnets}"
  acl_ingress_black_list = "${var.acl_ingress_black_list}"
  acl_egress_black_list  = "${var.acl_egress_black_list}"
}

module "security_group" {
  source                = "../shared/modules/security_group/"
  pjprefix              = "${var.pjprefix}"
  vpc_id                = "${module.network.vpc_id}"
  allow_alb_ingress_ips = "${var.allow_alb_ingress_ips}"
}

module "alb" {
  source               = "../shared/modules/alb"
  vpc_id               = "${module.network.vpc_id}"
  pjprefix             = "${var.pjprefix}"
  launch_subnet_ids    = "${module.network.public_subnet_ids}"
  security_group_ids   = "${[module.security_group.alb_sg_id]}"
  certification_domain = "${var.acm_domain}"
}
