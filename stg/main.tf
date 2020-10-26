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

module "alb_sg" {
  source = "../shared/modules/security_group"

  vpc_id            = var.network.vpc_id
  pjprefix          = var.pjprefix
  name              = "sg-alb-${var.pjprefix}"
  description       = var.alb_sg.description
  ingress_rule_list = var.alb_sg.ingress_rule_list
  egress_rule_list  = var.alb_sg.egress_rule_list
}
module "alb" {
  source               = "../shared/modules/alb"
  vpc_id               = "${module.network.vpc_id}"
  pjprefix             = "${var.pjprefix}"
  launch_subnet_ids    = "${module.network.public_subnet_ids}"
  security_group_ids   = "${[module.alb_sg.id]}"
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


module "elastic_cache_sg" {
  source = "../shared/modules/security_group"

  vpc_id            = var.network.vpc_id
  pjprefix          = var.pjprefix
  name              = "elastic-cache-sg-${var.pjprefix}"
  description       = var.elastic_cache_sg.description
  ingress_rule_list = var.elastic_cache_sg.ingress_rule_list
  egress_rule_list  = var.elastic_cache_sg.egress_rule_list
}
module "elastic_cache" {
  source = "../shared/modules/elastic_cache"

  is_create_parameter_group = var.elastic_cache_params.is_create_parameter_group
  parameter_group_vars      = var.elastic_cache_params.parameter_group_vars
  is_create_subnet_group    = var.elastic_cache_params.is_create_subnet_group
  subnet_ids                = module.network.elastic_cache_subnet_ids
  is_create_repl_group      = var.elastic_cache_params.is_create_repl_group
  repl_group_vars           = var.elastic_cache_params.repl_group_vars
  security_group_ids        = [module.elastic_cache_sg.id]
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


data "aws_iam_policy" "ecs_task_execution_role_policy" {
  # 固定 ARN
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
data "aws_iam_policy_document" "ecs_task_execution" {
  # デフォルトを継承する
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}
module "fargate_sg" {
  source = "../shared/modules/security_group"

  vpc_id            = var.network.vpc_id
  pjprefix          = var.pjprefix
  name              = var.security_group_params.fargate.name
  description       = var.security_group_params.fargate.description
  ingress_rule_list = var.security_group_params.fargate.ingress_rule_list
  egress_rule_list  = var.security_group_params.fargate.egress_rule_list
}
module "fargate_iam" {
  source     = "../shared/modules/iam"
  name       = "ecs-task-execution-${var.pjprefix}"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
  identifier = "ecs-tasks.amazonaws.com"
}
module "fargate" {
  source = "../shared/modules/fargate"

  pjprefix = var.pjprefix
  task_definition_params = {
    family                = var.fargate_params.task_definition.family
    cpu                   = var.fargate_params.task_definition.cpu
    memory                = var.fargate_params.task_definition.memory
    container_definitions = jsonencode(yamldecode(file(var.fargate_params.task_definition.container_definition)))
    execution_role_arn    = module.fargate_iam.iam_role_arn
  }
  ecs_service_params        = var.fargate_params.ecs_service
  security_group_ids        = [module.fargate_sg.id]
  subnet_ids                = module.network.web_subnet_ids
  target_group_arn          = module.alb.target_group_arn
  alb_attach_container_name = "nginx"
  alb_attach_container_port = 80
  ecs_logging_params        = var.fargate_params.ecs_logging_params
}
