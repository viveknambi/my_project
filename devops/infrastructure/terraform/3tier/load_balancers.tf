resource "random_id" "target_group_sufix" {
  byte_length = 2
}

################################################################################

resource "aws_alb_target_group" "api" {
  name     = "api-${var.environment_name}-${random_id.target_group_sufix.hex}"
  port     = "3000"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path = "/healthcheck"
    matcher = "200"
    interval = 10
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 6
  }

  tags {
    Name        = "api-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}

resource "aws_alb" "api" {
  name            = "api-${var.environment_name}"
  subnets         = ["${aws_subnet.frontend1.id}", "${aws_subnet.frontend2.id}"]
  security_groups = ["${aws_security_group.api_inbound.id}"]

  tags {
    Name        = "api-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}

resource "aws_alb_listener" "api_http" {
  load_balancer_arn = "${aws_alb.api.arn}"
  port              = "80"
  protocol          = "HTTP"
  depends_on        = ["aws_alb_target_group.api"]

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = 443
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "api_https" {
  load_balancer_arn = "${aws_alb.api.arn}"
  port              = "443"
  protocol          = "HTTPS"
  depends_on        = ["aws_alb_target_group.api"]

  certificate_arn = "${aws_acm_certificate_validation.api.certificate_arn}"
  depends_on      = [
    "aws_acm_certificate_validation.api"
  ]

  default_action {
    target_group_arn = "${aws_alb_target_group.api.arn}"
    type             = "forward"
  }
}

################################################################################

resource "aws_alb_target_group" "web" {
  name     = "web-${var.environment_name}-${random_id.target_group_sufix.hex}"
  port     = "3000"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path = "/healthcheck"
    matcher = "200"
    interval = 10
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 6
  }

  tags {
    Name        = "web-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}

resource "aws_alb" "web" {
  name            = "web-${var.environment_name}"
  subnets         = ["${aws_subnet.frontend1.id}", "${aws_subnet.frontend2.id}"]
  security_groups = ["${aws_security_group.web_inbound.id}"]

  tags {
    Name        = "web-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}

resource "aws_alb_listener" "web_http" {
  load_balancer_arn = "${aws_alb.web.arn}"
  port              = "80"
  protocol          = "HTTP"
  depends_on        = ["aws_alb_target_group.web"]

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = 443
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "web_https" {
  load_balancer_arn = "${aws_alb.web.arn}"
  port              = "443"
  protocol          = "HTTPS"

  certificate_arn = "${aws_acm_certificate_validation.web.certificate_arn}"
  depends_on      = [
    "aws_acm_certificate_validation.web"
  ]

  default_action {
    target_group_arn = "${aws_alb_target_group.web.arn}"
    type             = "forward"
  }
}
