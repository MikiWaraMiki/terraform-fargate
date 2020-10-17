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
