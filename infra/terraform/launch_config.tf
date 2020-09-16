# https://aws.amazon.com/premiumsupport/knowledge-center/eks-worker-nodes-cluster/?nc1=h_ls
locals {
  userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint "${aws_eks_cluster.cluster.endpoint}" --b64-cluster-ca "${aws_eks_cluster.cluster.certificate_authority.0.data}" "${aws_eks_cluster.cluster.name}"
USERDATA
}

data "aws_ami" "eks-node" {
  most_recent = true
  # Amazon EKS AMI Account ID
  owners = ["602401143452"]

  filter {
    name = "name"
    values=["amazon-eks-node-${local.cluster_version}-*"]
  }
}

resource "aws_launch_configuration" "lc" {
  iam_instance_profile = aws_iam_instance_profile.eks-node.id
  image_id = data.aws_ami.eks-node.image_id
  instance_type = var.instance_type
  name_prefix = "${local.base_name}-node"
  key_name = var.key_name

  root_block_device {
    volume_type = "gp2"
    volume_size = "50"
  }

  security_groups = [aws_security_group.eks-node.id]
  user_data_base64 = base64encode(local.userdata)

  lifecycle {
    create_before_destroy = true
  }

  # To ensure IAM policies are created before
  depends_on = [
    aws_iam_role_policy_attachment.eks-worker-node,
    aws_iam_role_policy_attachment.eks-cni,
    aws_iam_role_policy_attachment.ecr-readonly
  ]
}
