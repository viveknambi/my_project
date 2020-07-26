resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Name = "${var.application_name}-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}

resource "aws_route_table" "db_primary" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
  tags {
    Name = "db1-${var.application_name}-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}
resource "aws_route_table_association" "db_primary" {
  subnet_id = "${aws_subnet.db_primary.id}"
  route_table_id = "${aws_route_table.db_primary.id}"
}

resource "aws_route_table" "db_secondary" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
  tags {
    Name = "db2-${var.application_name}-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}
resource "aws_route_table_association" "db_secondary" {
  subnet_id = "${aws_subnet.db_secondary.id}"
  route_table_id = "${aws_route_table.db_secondary.id}"
}

resource "aws_route_table" "traffic" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
  tags {
    Name = "traffic-${var.application_name}-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}
resource "aws_route_table_association" "traffic1" {
  subnet_id = "${aws_subnet.frontend1.id}"
  route_table_id = "${aws_route_table.traffic.id}"
}
resource "aws_route_table_association" "traffic2" {
  subnet_id = "${aws_subnet.frontend2.id}"
  route_table_id = "${aws_route_table.traffic.id}"
}
