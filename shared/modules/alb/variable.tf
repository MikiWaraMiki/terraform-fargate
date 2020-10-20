variable "vpc_id" {
  type    = string
  default = ""
}
variable "pjprefix" {
  type    = string
  default = ""
}
variable "launch_subnet_ids" {
  type    = list(string)
  default = []
}
variable "security_group_ids" {
  type    = list(string)
  default = []
}
variable "enable_delete_protection" {
  type    = bool
  default = true
}
variable "is_internal" {
  type    = bool
  default = false
}
variable "idle_timeout" {
  type    = number
  default = 60
}
variable "access_logs_bucket" {
  //type = object({
  //  bucket  = string
  //  prefix  = string
  //  enabled = bool
  //})
  //default = {
  //  bucket  = null,
  //  prefix  = null,
  //  enabled = null,
  //}
  default = {}
}
variable "target_group_health_check" {
  type = object({
    enabled             = bool,
    interval            = number,
    path                = string,
    port                = number,
    protocol            = string,
    timeout             = number,
    healthy_threshold   = number,
    unhealthy_threshold = number,
    matcher             = string
  })
  default = {
    enabled             = true,
    interval            = 15,
    path                = "/",
    port                = 80,
    protocol            = "HTTP",
    timeout             = 5,
    healthy_threshold   = 3,
    unhealthy_threshold = 5,
    matcher             = "200"
  }
}

variable "certification_arn" {
  type    = string
  default = ""
}
variable "certification_domain" {
  type    = string
  default = ""
}
