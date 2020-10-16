variable "vpc_cidr" {
  type    = string
  default = "0.0.0.0/0"
}
variable "enable_dns_support" {
  type    = bool
  default = true
}
variable "enable_dns_hostnames" {
  type    = bool
  default = true
}
variable "instance_tenancy" {
  default = "default"
}

variable "pjprefix" {
  type = string
}
variable "name" {
  type = string
}

#######################
# Create VPC
#######################
resource "aws_vpc" "main" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "${var.instance_tenancy}"

  tags = {
    PJPrefix = "${var.pjprefix}"
    Name     = "${var.name}"
  }
}
#######################
# Create DHCP Option
#######################


output "vpc_id" {
  description = "The ID of the vpc"
  value       = "${aws_vpc.main.id}"
}
