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


module "route53_alb" {
  source = "../shared/modules/route53"

  pjprefix            = "${var.pjprefix}"
  is_create_host_zone = "${var.is_create_host_zone}"
  zone_name           = "${var.zone_name}"
  # ALBのエイリアス追加
  route_list = [{
    name        = "${var.acm_domain}",
    record_type = "A",
    ttl         = null,
    records     = null,
    alias_config = {
      name                   = "${module.alb.alb_dns_name}",
      zone_id                = "${module.alb.alb_zone_id}",
      evaluate_target_health = true
    }
  }]

  depends_on = [module.alb]
}


module "elastic_cache" {
  source = "../shared/modules/elastic_cache"

  is_create_parameter_group = var.elastic_cache_params.is_create_parameter_group
  parameter_group_vars      = var.elastic_cache_params.parameter_group_vars
  is_create_subnet_group    = var.elastic_cache_params.is_create_subnet_group
  subnet_ids                = module.network.elastic_cache_subnet_ids
  is_create_repl_group      = var.elastic_cache_params.is_create_repl_group
  repl_group_vars           = var.elastic_cache_params.repl_group_vars
  security_group_ids        = [module.security_group.elastic_cache_sg_id]
  pjprefix                  = var.pjprefix
}


module "ecr" {
  source = "../shared/modules/ecr"

  pjprefix                      = var.pjprefix
  tag_mutability                = var.ecr_params.tag_mutability
  scanning_enable               = var.ecr_params.scanning_enable
  is_create_lifecycle           = var.ecr_params.is_create_lifecycle
  decoded_json_lifecycle_policy = var.ecr_params.is_create_lifecycle ? jsonencode(yamldecode(file(var.ecr_params.decoded_json_lifecycle_policy))) : ""
  is_create_ecr_policy          = var.ecr_params.is_create_ecr_policy
  decoded_json_ecr_policy       = var.ecr_params.is_create_ecr_policy ? jsonencode(yamldecode(file(var.ecr_params.ecr_policy_file))) : ""
}
