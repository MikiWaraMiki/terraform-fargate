variable "vpc_cidr" {}
variable "pjprefix" {}
variable "public_subnets" {}
# Launch Web Server Subnets...
variable "web_subnets" {}
# Launch RDS Subnets
variable "database_subnets" {}
# Launch ElasticCache Subnets
variable "elastic_cache_subnets" {}
# Ingress Black List ACL
variable "acl_ingress_black_list" {}
# Ingress Black List ACL
variable "acl_egress_black_list" {}

module "vpc" {
  source   = "./vpc"
  name     = "${var.pjprefix}-vpc"
  vpc_cidr = "${var.vpc_cidr}"
  pjprefix = "${var.pjprefix}"
}

module "subnet" {
  source                = "./subnets"
  vpc_id                = "${module.vpc.vpc_id}"
  public_subnets        = "${var.public_subnets}"
  web_subnets           = "${var.web_subnets}"
  database_subnets      = "${var.database_subnets}"
  elastic_cache_subnets = "${var.elastic_cache_subnets}"
  pjprefix              = "${var.pjprefix}"
}

module "acl" {
  source = "./acls"
  vpc_id = "${module.vpc.vpc_id}"
  subnet_ids = "${concat(
    module.subnet.public_subnet_ids,
    module.subnet.web_subnet_ids,
    module.subnet.database_subnet_ids,
    module.subnet.elastic_cache_subnet_ids)
  }"
  pjprefix           = "${var.pjprefix}"
  ingress_black_list = "${var.acl_ingress_black_list}"
  egress_black_list  = "${var.acl_egress_black_list}"
}
