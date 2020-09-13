resource "aws_eks_cluster" "cluster" {
  name = local.cluster_name
  role_arn = aws_iam_role.eks-master.arn
  version = local.cluster_version

  vpc_config {
    security_group_ids = [aws_security_group.eks-master.id]
    subnet_ids = concat(aws_subnet.public_subnet.*.id, aws_subnet.private_subnet.*.id)
  }

  # To ensure IAM policies are created before
  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster,
    aws_iam_role_policy_attachment.eks-service
  ]
}
