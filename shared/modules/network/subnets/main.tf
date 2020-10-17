variable "vpc_id" {
  description = "VPC id"
  type        = string
  default     = ""
}
# Launch ALB Subnets
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
# Tag PJPrefix
variable "pjprefix" {
  description = "Project Suffix"
  type        = string
  default     = ""
}

#######################
# Create Public Subnet
#######################
resource "aws_subnet" "public_subnets" {
  count             = "${length(var.public_subnets)}"
  vpc_id            = "${var.vpc_id}"
  availability_zone = "${lookup(element(var.public_subnets, count.index), "az")}"
  cidr_block        = "${lookup(element(var.public_subnets, count.index), "cidr")}"
  # public subnets enable globalip
  map_public_ip_on_launch = true
  tags = {
    "PJPrefix" = "${var.pjprefix}"
    "Name"     = "${lookup(element(var.public_subnets, count.index), "name")}"
  }
}


#######################
# Create web Subnet
#######################
resource "aws_subnet" "web_subnets" {
  count             = "${length(var.web_subnets)}"
  vpc_id            = "${var.vpc_id}"
  availability_zone = "${lookup(element(var.web_subnets, count.index), "az")}"
  cidr_block        = "${lookup(element(var.web_subnets, count.index), "cidr")}"
  tags = {
    "PJPrefix" = "${var.pjprefix}"
    "Name"     = "${lookup(element(var.web_subnets, count.index), "name")}"
  }
}

#######################
# Create DB Subnet
#######################
resource "aws_subnet" "database_subnets" {
  count             = "${length(var.database_subnets)}"
  vpc_id            = "${var.vpc_id}"
  availability_zone = "${lookup(element(var.database_subnets, count.index), "az")}"
  cidr_block        = "${lookup(element(var.database_subnets, count.index), "cidr")}"
  tags = {
    "PJPrefix" = "${var.pjprefix}"
    "Name"     = "${lookup(element(var.database_subnets, count.index), "name")}"
  }
}

#############################
# Create ElasticCache Subnet
#############################
resource "aws_subnet" "elastic_cache_subnets" {
  count             = "${length(var.elastic_cache_subnets)}"
  vpc_id            = "${var.vpc_id}"
  availability_zone = "${lookup(element(var.elastic_cache_subnets, count.index), "az")}"
  cidr_block        = "${lookup(element(var.elastic_cache_subnets, count.index), "cidr")}"
  tags = {
    "PJPrefix" = "${var.pjprefix}"
    "Name"     = "${lookup(element(var.elastic_cache_subnets, count.index), "name")}"
  }
}



#######################
# Create IGW
#######################
resource "aws_internet_gateway" "main_vpc_igw" {
  vpc_id = "${var.vpc_id}"
  tags = {
    "Name"     = "igw-${var.pjprefix}"
    "PJPrefix" = "${var.pjprefix}"
  }
}
#######################
# Create NAT GW
#######################
resource "aws_eip" "main_vpc_ngw" {
  count = "${length(aws_subnet.public_subnets.*.id)}"
  vpc   = true

  tags = {
    "Name"     = "eip-${count.index}-${var.pjprefix}"
    "PJPrefix" = "${var.pjprefix}"
  }
}
resource "aws_nat_gateway" "ngw" {
  count         = "${length(aws_subnet.public_subnets.*.id)}"
  allocation_id = "${element(aws_eip.main_vpc_ngw.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public_subnets.*.id, count.index)}"

  tags = {
    "Name"     = "ngw-${count.index}-${var.pjprefix}"
    "PJPrefix" = "${var.pjprefix}"
  }
}

############################
# Public Route Table
############################
resource "aws_route_table" "public_route_table" {
  vpc_id = "${var.vpc_id}"

  tags = {
    "Name"     = "rt-public-${var.pjprefix}"
    "PJPrefix" = "${var.pjprefix}"
  }
}
# Route
resource "aws_route" "route_for_public" {
  route_table_id         = "${aws_route_table.public_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main_vpc_igw.id}"

  # timeout5分に設定
  timeouts {
    create = "5m"
  }
}
# Route Table Associate
resource "aws_route_table_association" "route_table_association_for_public" {
  count          = "${length(aws_subnet.public_subnets.*.id)}"
  subnet_id      = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

############################
# Private Route Table
############################
resource "aws_route_table" "private_route_table" {
  count  = "${length(aws_subnet.web_subnets.*.id)}"
  vpc_id = "${var.vpc_id}"
  tags = {
    "Name"     = "rt${count.index}-private-${var.pjprefix}"
    "PJPrefix" = "${var.pjprefix}"
  }
}
# Route
resource "aws_route" "route_for_web" {
  count                  = "${length(aws_route_table.private_route_table.*.id)}"
  route_table_id         = "${element(aws_route_table.private_route_table.*.id, count.index)}"
  nat_gateway_id         = "${element(aws_nat_gateway.ngw.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"

  timeouts {
    create = "5m"
  }
}
# Route Table Association for Web
resource "aws_route_table_association" "route_table_association_for_web" {
  count          = "${length(aws_route_table.private_route_table.*.id)}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.web_subnets.*.id, count.index)}"
}
# Route Table Association for RDS
resource "aws_route_table_association" "route_table_association_for_database" {
  count          = "${length(aws_route_table.private_route_table.*.id)}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.database_subnets.*.id, count.index)}"
}
# Route Table Association for Elastic Cache
resource "aws_route_table_association" "route_table_association_for_elasticcache" {
  count          = "${length(aws_route_table.private_route_table.*.id)}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.elastic_cache_subnets.*.id, count.index)}"
}


output "public_subnet_ids" {
  description = "subnet ids for alb"
  value       = "${aws_subnet.public_subnets.*.id}"
}
output "web_subnet_ids" {
  description = "subnet ids for web server"
  value       = "${aws_subnet.web_subnets.*.id}"
}

output "database_subnet_ids" {
  description = "subent ids for database"
  value       = "${aws_subnet.database_subnets.*.id}"
}

output "elastic_cache_subnet_ids" {
  description = "subnet ids for elastic cache"
  value       = "${aws_subnet.elastic_cache_subnets.*.id}"
}
