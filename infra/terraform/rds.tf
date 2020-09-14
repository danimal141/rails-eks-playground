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
