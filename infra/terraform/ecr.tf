resource "aws_ecr_repository" "ecr" {
  name = local.base_name
}
