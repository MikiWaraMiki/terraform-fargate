variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}
variable "pjprefix" {
  description = "Project Prefix"
  type        = string
}
variable "public_subnets" {
  description = "A list of public subnets inside the VPC."
  type = list(object({
    cidr = string,
    name = string,
    az   = string
  }))
  default = []
}
# Launch Web Server Subnets...
variable "web_subnets" {
  description = "A list of private subnets inside the VPC."
  type = list(object({
    cidr = string,
    name = string,
    az   = string
  }))
  default = []
}
# Launch RDS Subnets
variable "database_subnets" {
  description = "A list of database subnets inside the VPC."
  type = list(object({
    cidr = string,
    name = string,
    az   = string
  }))
  default = []
}
# Launch ElasticCache Subnets
variable "elastic_cache_subnets" {
  description = "A list of ElasticCache subnets inside the VPC."
  type = list(object({
    cidr = string,
    name = string,
    az   = string
  }))
  default = []
}

module "vpc" {
  source = "./vpc"

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
