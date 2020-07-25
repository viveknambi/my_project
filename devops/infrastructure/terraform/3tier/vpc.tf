resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr_prefix}.${var.vpc_cidr_suffix}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.application_name}-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
  lifecycle { create_before_destroy = true }
}
