resource "aws_autoscaling_group" "eks-asg" {
  name = "eks-node-autoscalling-group"
  desired_capacity = var.asg_desired_capacity
  launch_configuration = aws_launch_configuration.lc.id
  max_size = var.asg_max_size
  min_size = var.asg_min_size
  vpc_zone_identifier = aws_subnet.private_subnet.*.id

  tag {
    key = "Name"
    value = "${local.base_name}-eks-asg"
    propagate_at_launch = true
  }

  tag {
    key = "kubernetes.io/cluster/${local.cluster_name}"
    value = "owned"
    propagate_at_launch = true
  }

  tag {
    key = "Project"
    value = var.project
    propagate_at_launch = true
  }

  tag {
    key = "ManagedBy"
    value = "Terraform"
    propagate_at_launch = true
  }

  tag {
    key = "Environment"
    value = var.environment
    propagate_at_launch = true
  }
}
