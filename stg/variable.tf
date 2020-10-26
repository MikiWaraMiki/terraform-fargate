# These variable read by tfvar files
variable "region" {}
variable "profile" {}

# Project Variables
variable "pjprefix" {
  default = "stg-tf-test"
}
variable "vpc_cidr" {
  default = "172.17.0.0/16"
}
variable "public_subnets" {
  default = [
    {
      cidr = "172.17.0.0/24",
      name = "stg-public-subnet-1a",
      az   = "ap-northeast-1a"
    },
    {
      cidr = "172.17.1.0/24",
      name = "stg-public-subnet-1c",
      az   = "ap-northeast-1c"
    }
  ]
}
variable "web_subnets" {
  default = [
    {
      cidr = "172.17.10.0/24",
      name = "stg-web-subnet-1a",
      az   = "ap-northeast-1a"
    },
    {
      cidr = "172.17.11.0/24",
      name = "stg-web-subnet-1c",
      az   = "ap-northeast-1c"
    }
  ]
}
variable "database_subnets" {
  default = [
    {
      cidr = "172.17.20.0/24",
      name = "stg-database-subnet-1a",
      az   = "ap-northeast-1a"
    },
    {
      cidr = "172.17.21.0/24",
      name = "stg-database-subnet-1c",
      az   = "ap-northeast-1c"
    }
  ]
}
variable "elastic_cache_subnets" {
  default = [
    {
      cidr = "172.17.22.0/24",
      name = "stg-elastic-cache-subnet-1a",
      az   = "ap-northeast-1a"
    },
    {
      cidr = "172.17.23.0/24",
      name = "stg-elastic-cache-subnet-1c",
      az   = "ap-northeast-1c"
    }
  ]
}
variable "acl_ingress_black_list" {
  default = [
    {
      protocol   = "tcp"
      rule_no    = "1"
      cidr_block = "34.83.207.109/32"
      from_port  = 80,
      to_port    = 80
    },
    {
      protocol   = "tcp"
      rule_no    = "2"
      cidr_block = "34.83.207.109/32"
      from_port  = 443,
      to_port    = 443
    },
  ]
}
variable "acl_egress_black_list" {
  default = []
}
variable "allow_alb_ingress_ips" {
  default = []
}
# ALB
variable "alb_sg" {
  default = {
    description = "ALB Security Group. Ingress Allow HTTP, HTTPS"
    ingress_rule_list = [
      {
        description       = "allow http from all"
        to_port           = 80
        from_port         = 80
        protocol          = "tcp"
        security_group_id = null
        cidr_blocks       = ["0.0.0.0/0"]
      },
      {
        description       = "allow https from all"
        to_port           = 443
        to_port           = 443
        protocol          = "tcp"
        security_group_id = null
        cidr_blocks       = ["0.0.0.0/0"]
      }
    ]
    egress_rule_list = [
      {
        description = "all allow"
        to_port     = 65535
        from_port   = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}
variable "acm_domain" {
}

# Route53
variable "is_create_host_zone" {
  default = false
}
variable "zone_name" {
}

# Elastic Cache
variable "elastic_cache_sg" {
  default = {
    description = "Elastic Cache Securiy Group allow"
    ingress_rule_list = [
      {
        description = "allow redis from fargate"
      }
    ]
  }
}
variable "elastic_cache_params" {
  default = {
    is_create_parameter_group : true,
    parameter_group_vars : {
      family = "redis5.0"
      parameters = [
        {
          name  = "cluster-enabled",
          value = "no"
        }
      ]
    },
    is_create_subnet_group : true,
    is_create_repl_group : true,
    repl_group_vars : {
      engine                   = "redis",
      engine_version           = "5.0.6"
      number_cache_clusters    = 2,
      node_type                = "cache.t3.micro",
      snapshot_window          = "18:10-19:10",
      snapshot_retention_limit = "2",
      maintenance_window       = "sun:19:45-sun:20:45",
      port                     = 6379,
      apply_immediately        = false,
    }
  }
}

# ECR
variable "ecr_params" {
  default = {
    tag_mutability                = "MUTABLE",
    scanning_enable               = true,
    is_create_lifecycle           = true,
    decoded_json_lifecycle_policy = "./variable/ecr/lifecycle_policy.yml",
    is_create_ecr_policy          = false,
  }
}

# Fargate
variable "fargate_params" {
  default = {
    task_definition = {
      family               = "stg-fargate"
      cpu                  = "256"
      memory               = "512"
      container_definition = "./variable/fargate/task_definition.yml"
    },
    ecs_service = {
      desired_count                     = 2
      platform_version                  = "1.4.0"
      health_check_grace_period_seconds = 60
      assign_public_ip                  = false
    },
    ecs_logging_params = {
      retention_in_days = 180
    }
  }
}
