##############################
# Create LoadBalancer
##############################
resource "aws_lb" "main_alb" {
  name               = "alb-${var.pjprefix}"
  load_balancer_type = "application"
  internal           = "${var.is_internal}"
  idle_timeout       = "${var.idle_timeout}"

  subnets         = "${var.launch_subnet_ids}"
  security_groups = "${var.security_group_ids}"

  enable_deletion_protection = "${var.enable_delete_protection}"

  dynamic "access_logs" {
    for_each = length(keys(var.access_logs_bucket)) == 0 ? [] : [var.access_logs_bucket]
    content {
      enabled = lookup(access_logs.value, "enabled", lookup(access_logs.value, "bucket", null) != null)
      bucket  = lookup(access_logs.value, "bucket", null)
      prefix  = lookup(access_logs.value, "prefix", null)
    }
  }
  tags = {
    Name     = "alb-${var.pjprefix}"
    PJPrefix = "${var.pjprefix}"
  }

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}
# target group
resource "aws_lb_target_group" "main_alb_tg" {
  name     = "tg-${var.pjprefix}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  target_type          = "ip"
  deregistration_delay = 20

  dynamic "health_check" {
    for_each = length(keys(var.target_group_health_check)) == 0 ? [] : [var.target_group_health_check]

    content {
      enabled             = lookup(health_check.value, "enabled", null)
      interval            = lookup(health_check.value, "interval", null)
      path                = lookup(health_check.value, "path", null)
      port                = lookup(health_check.value, "port", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
      timeout             = lookup(health_check.value, "timeout", null)
      protocol            = lookup(health_check.value, "protocol", null)
      matcher             = lookup(health_check.value, "matcher", null)
    }
  }

  tags = {
    Name     = "tg-${var.pjprefix}"
    PJPrefix = "${var.pjprefix}"
  }

  depends_on = [aws_lb.main_alb]
  lifecycle {
    create_before_destroy = true
  }
}
# Listener
data "aws_acm_certificate" "alb_domain" {
  count    = var.certification_domain == "" ? 0 : 1
  domain   = "${var.certification_domain}"
  statuses = ["ISSUED"]
}

resource "aws_lb_listener" "frontend_https" {
  count             = var.certification_domain == "" ? 0 : 1
  load_balancer_arn = "${aws_lb.main_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.aws_acm_certificate.alb_domain[0].arn}"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.main_alb_tg.arn}"
  }
}
resource "aws_lb_listener" "frontend_http" {
  load_balancer_arn = "${aws_lb.main_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
