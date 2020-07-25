resource "aws_subnet" "db_primary" {
  vpc_id = "${aws_vpc.main.id}"
  availability_zone = "us-east-1d"
  cidr_block = "${var.vpc_cidr_prefix}.20.0/24"
  map_public_ip_on_launch = false
  depends_on = ["aws_internet_gateway.main"]
  tags {
    Name = "primary-${var.application_name}-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}
resource "aws_subnet" "db_secondary" {
  vpc_id = "${aws_vpc.main.id}"
  availability_zone = "us-east-1e"
  cidr_block = "${var.vpc_cidr_prefix}.30.0/24"
  map_public_ip_on_launch = false
  depends_on = ["aws_internet_gateway.main"]
  tags {
    Name = "secondary-${var.application_name}-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}

resource "aws_subnet" "frontend1" {
  vpc_id = "${aws_vpc.main.id}"
  availability_zone = "us-east-1c"
  cidr_block = "${var.vpc_cidr_prefix}.33.0/24"
  map_public_ip_on_launch = true
  depends_on = ["aws_internet_gateway.main"]
  tags {
    Name = "frontend1-${var.application_name}-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}
resource "aws_subnet" "frontend2" {
  vpc_id = "${aws_vpc.main.id}"
  availability_zone = "us-east-1a"
  cidr_block = "${var.vpc_cidr_prefix}.32.0/24"
  map_public_ip_on_launch = true
  depends_on = ["aws_internet_gateway.main"]
  tags {
    Name = "frontend2-${var.application_name}-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}
