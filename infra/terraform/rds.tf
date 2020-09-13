resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.vpc.id
  name = "rds-sg"

  ingress {
    protocol = "tcp"
    from_port = 5432
    to_port = 5432
    security_groups = [aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id]
  }

  tags = merge(local.base_tags, { "Name" = "${local.base_name}-rds-sg" })
}

resource "aws_db_subnet_group" "default" {
  name = "${local.base_name}-db-subnet-group"
  subnet_ids = aws_subnet.private_subnet.*.id

  tags = merge(local.base_tags, { "Name" = "${local.base_name}-db-subnet-group" })
}

resource "aws_db_instance" "rds" {
  allocated_storage = 5
  db_subnet_group_name = aws_db_subnet_group.default.name
  instance_class = var.db_instance_type
  engine = "postgres"
  engine_version = "11.6"
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot = true

  port = 5432
  username = var.db_username
  password = var.db_password

  tags = merge(local.base_tags, { "Name" = "${local.base_name}-db" })
}
