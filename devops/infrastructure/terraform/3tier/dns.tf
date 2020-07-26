data "aws_route53_zone" "dns" {
  name = "${var.dns_zone}"
}

# Even though this is all "web", it uses the "web_backend_name" so that the
# CloudFront distribution can use the "web_name"
resource "aws_route53_record" "web" {
  zone_id = "${data.aws_route53_zone.dns.zone_id}"
  name    = "${var.web_backend_name}.${data.aws_route53_zone.dns.name}"
  type    = "A"

  alias {
    name                   = "${aws_alb.web.dns_name}"
    zone_id                = "${aws_alb.web.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "web" {
  domain_name       = "${aws_route53_record.web.name}"
  validation_method = "DNS"

  tags {
    Name = "web-${var.application_name}-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}

resource "aws_route53_record" "web_validation" {
  name    = "${aws_acm_certificate.web.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.web.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.dns.id}"
  ttl     = 60
  records = [
    "${aws_acm_certificate.web.domain_validation_options.0.resource_record_value}"
  ]
}

resource "aws_acm_certificate_validation" "web" {
  certificate_arn = "${aws_acm_certificate.web.arn}"
  validation_record_fqdns = [
    "${aws_route53_record.web_validation.fqdn}",
  ]
}

resource "aws_route53_record" "api" {
  zone_id = "${data.aws_route53_zone.dns.zone_id}"
  name    = "${var.api_name}.${data.aws_route53_zone.dns.name}"
  type    = "A"

  alias {
    name                   = "${aws_alb.api.dns_name}"
    zone_id                = "${aws_alb.api.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "api" {
  domain_name       = "${aws_route53_record.api.name}"
  validation_method = "DNS"

  tags {
    Name = "api-${var.application_name}-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}

resource "aws_route53_record" "api_validation" {
  name    = "${aws_acm_certificate.api.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.api.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.dns.id}"
  ttl     = 60
  records = [
    "${aws_acm_certificate.api.domain_validation_options.0.resource_record_value}"
  ]
}

resource "aws_acm_certificate_validation" "api" {
  certificate_arn = "${aws_acm_certificate.api.arn}"
  validation_record_fqdns = [
    "${aws_route53_record.api_validation.fqdn}",
  ]
}
