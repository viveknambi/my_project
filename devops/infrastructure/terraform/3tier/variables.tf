# Variables that require definition via env-var or parameter

variable "environment_name" {
  type = "string"
  description = "Environment name"
  default = "production"
}
variable "application_name" {
  type = "string"
  description = "Application name"
  default = "3Tier"
}
variable "region" {
  type = "string"
  description = "Amazon AWS region"
  default = "us-east-1"
}

variable "vpc_cidr_prefix" {
  type = "string"
  description = "Fist two octets of VPC CIDR"
  default = "10.10"
}
variable "vpc_cidr_suffix" {
  type = "string"
  description = "Last two octets of VPC network and bitmask count"
  default = "0.0/16"
}

variable "dns_zone" {
  type = "string"
  description = "Registered DNS name of Route53 zone to put all DNS names"
}
variable "web_name" {
  type = "string"
  description = "Registered DNS name of Route53 zone to put all DNS names"
  default = "www"
}
variable "web_backend_name" {
  type = "string"
  description = "Registered DNS name of Route53 zone to put all DNS names"
  default = "www-backend"
}
variable "api_name" {
  type = "string"
  description = "Registered DNS name of Route53 zone to put all DNS names"
  default = "api"
}

variable "root_db_user" {
  type = "string"
  description = "Root database password"
  default = "dba"
}
variable "root_db_password" {
  type = "string"
  description = "Root database password"
  default = "Thisistherootpassword."
}
variable "db_name" {
  type = "string"
  description = "Application database name"
  default = "three_tier"
}
variable "db_port" {
  type = "string"
  description = "Database port"
  default = "5432"
}
variable "rds_days_of_backups_to_retain" {
  type = "string"
  description = "Number of backups to retain (0 to disable)"
  default = "3"
}
variable "rds_multi_az" {
  type = "string"
  description = "Is this database multi-availability-zone or not?"
  default = "true"
}
variable "rds_instance_class" {
  type = "string"
  description = "Independently configure server class/size"
  default = "db.m3.medium"
}
variable "rds_encrypted" {
  type = "string"
  description = "Is the database encrypted at rest?"
  default = "true"
}
