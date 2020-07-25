resource "aws_route53_record" "cdn" {
  zone_id = "${data.aws_route53_zone.dns.zone_id}"
  name    = "${var.web_name}.${data.aws_route53_zone.dns.name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.web.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.web.hosted_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "cdn" {
  domain_name       = "${var.web_name}.${data.aws_route53_zone.dns.name}"
  validation_method = "DNS"

  tags {
    Name = "cdn-${var.application_name}-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}

resource "aws_route53_record" "cdn_validation" {
  name    = "${aws_acm_certificate.cdn.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cdn.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.dns.id}"
  ttl     = 60
  records = [
    "${aws_acm_certificate.cdn.domain_validation_options.0.resource_record_value}"
  ]
}

resource "aws_acm_certificate_validation" "cdn" {
  certificate_arn = "${aws_acm_certificate.cdn.arn}"
  validation_record_fqdns = [
    "${aws_route53_record.cdn_validation.fqdn}",
  ]
}

# Need to add:
#  * logging_config {}
resource "aws_cloudfront_distribution" "web" {
  enabled     = "true"
  price_class = "PriceClass_100"

  aliases = [
    "${var.web_name}.${var.dns_zone}",
  ]

  viewer_certificate {
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
    acm_certificate_arn      = "${aws_acm_certificate.cdn.arn}"
  }

  origin {
    origin_id   = "web_alb"
    domain_name = "www-backend.3tier.robkinyon.org"

    custom_origin_config {
      http_port  = "80"
      https_port = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = [ "TLSv1.2" ]
    }
  }

  ordered_cache_behavior {
    allowed_methods = [ "GET", "HEAD", "OPTIONS" ]
    cached_methods  = [ "GET", "HEAD" ]
    compress        = "true"

    path_pattern = "/images/*"

    target_origin_id = "web_alb"

    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 0
    max_ttl     = 86400
    default_ttl = 60

    forwarded_values {
      headers = [ "*" ]
      query_string = "true"
      cookies {
        forward = "all"
      }
    }
  }

  ordered_cache_behavior {
    allowed_methods = [ "GET", "HEAD", "OPTIONS" ]
    cached_methods  = [ "GET", "HEAD" ]
    compress        = "true"

    path_pattern = "/stylesheets/*"

    target_origin_id = "web_alb"

    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 0
    max_ttl     = 86400
    default_ttl = 60

    forwarded_values {
      headers = [ "*" ]
      query_string = "true"
      cookies {
        forward = "all"
      }
    }
  }

  default_cache_behavior {
    allowed_methods = [ "GET", "HEAD", "OPTIONS" ]
    cached_methods  = [ "GET", "HEAD" ]
    compress        = "true"

    target_origin_id = "web_alb"

    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 0
    max_ttl     = 0
    default_ttl = 0

    forwarded_values {
      headers = [ "*" ]
      query_string = "true"
      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags {
    Name = "${var.application_name}-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}
