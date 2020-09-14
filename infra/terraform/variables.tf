variable "region" {
  default = "ap-northeast-1"
}

variable "project" {
  default = "sample-api"
}

variable "environment" {
  default = "production"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnet_count" {
  default = 2
}

variable "instance_type" {
  default = "t2.small"
}

variable "db_instance_type" {
  default = "db.t2.micro"
}

variable "key_name" {
  # Override
  # Key name for EC2 instances
  # Can find the existent key names from `aws ec2 describe-key-pairs`
}

variable "db_username" {
  # Override
  # RDS db username
  default = "dbuser"
}

variable "db_password" {
  # Override
  # RDS db password
  # Should be at least 8 characters
  default = "dbpassword"
}

variable "asg_desired_capacity" {
  default = 2
}

variable "asg_max_size" {
  default = 2
}

variable "asg_min_size" {
  default = 2
}

locals {
  base_tags = {
    Project = var.project
    ManagedBy = "Terraform"
    Environment = var.environment
  }

  cluster_base_tags = merge(local.base_tags, map("kubernetes.io/cluster/${local.cluster_name}", "shared"))
  base_name = "${var.project}-${var.environment}"
  cluster_name = "${local.base_name}-cluster"
  cluster_version = "1.17"
}
