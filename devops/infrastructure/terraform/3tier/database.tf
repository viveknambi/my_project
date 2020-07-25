resource "aws_db_subnet_group" "main" {
  name = "${var.environment_name}"
  description = "Our Main RDS subnet group"
  subnet_ids = [
    "${aws_subnet.db_primary.id}",
    "${aws_subnet.db_secondary.id}",
  ]

  tags {
    Name = "${var.application_name}-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}

resource "aws_db_parameter_group" "main" {
  name = "three-tier"
  family = "postgres9.4"
}

resource "aws_db_instance" "main" {
  identifier = "three-tier"
  username = "${var.root_db_user}"
  password = "${var.root_db_password}"
  name = "${var.db_name}"
  backup_retention_period = "${var.rds_days_of_backups_to_retain}"

  instance_class = "${var.rds_instance_class}"
  engine = "postgres"
  engine_version = "9.4"
  parameter_group_name = "${aws_db_parameter_group.main.name}"

  storage_type = "standard"
  storage_encrypted = "${var.rds_encrypted}"
  allocated_storage = "10"

  multi_az = "${var.rds_multi_az}"
  publicly_accessible = "false"

  apply_immediately = "true"
  skip_final_snapshot = "true"

  vpc_security_group_ids = [
    "${aws_security_group.db_instance.id}",
  ]

  db_subnet_group_name = "${aws_db_subnet_group.main.name}"

  tags {
    Name = "${var.application_name}-${var.environment_name}"
    Environment = "${var.environment_name}"
  }
}
