# FIRST PASS ONLY: comment out this section because the state store doesn't
# exist yet.
terraform {
  backend "s3" {
    encrypt = true
    bucket = "robkinyon-3tier-operations"
    dynamodb_table = "3tier-lock"
    region = "us-east-1"
    key = "terraform/state/devops.tfstate"
  }
}
# TO HERE

provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "tf-remote-state" {
  bucket = "${var.remote_state_s3_bucket}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "${var.remote_state_s3_bucket}"
    Environment = "${var.environment_name}"
  }
}

resource "aws_dynamodb_table" "tfstate-lock" {
  name = "${var.lock_table}"
  hash_key = "LockID"

  read_capacity = 1
  write_capacity = 1

  attribute = {
    name = "LockID"
    type = "S"
  }

  lifecycle = {
    prevent_destroy = true
  }

  tags {
    Name = "${var.lock_table}"
    Environment = "${var.environment_name}"
  }
}
