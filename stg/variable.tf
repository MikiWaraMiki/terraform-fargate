variable "region" {}

variable "profile" {}

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
