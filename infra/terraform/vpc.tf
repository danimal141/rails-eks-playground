data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"
  tags = merge(local.base_tags, { "Name" = "${local.base_name}-vpc" })
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  count = var.subnet_count
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index % var.subnet_count)
  map_public_ip_on_launch = true
  tags = merge(local.cluster_base_tags, { "Name" = "${local.base_name}-public-subnet-${count.index + 1}" })
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.vpc.id
  count = var.subnet_count
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, var.subnet_count + count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index % var.subnet_count)
  map_public_ip_on_launch = false
  tags = merge(local.cluster_base_tags, { "Name" = "${local.base_name}-private-subnet-${count.index + 1}" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.base_tags, { "Name" = "${local.base_name}-igw" })
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.base_tags, { "Name" = "${local.base_name}-rt" })
}

resource "aws_route_table_association" "rta" {
  count = var.subnet_count
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "eks-master" {
  vpc_id = aws_vpc.vpc.id
  name = "${local.base_name}-master-sg"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.base_tags, { "Name" = "${local.base_name}-eks-master-sg" })
}

resource "aws_security_group" "eks-node" {
  vpc_id = aws_vpc.vpc.id
  name = "${local.base_name}-node-sg"

  ingress {
    description = "Allow cluster master to access cluster nodes"
    from_port = 1025
    to_port = 65535
    protocol = "tcp"
    security_groups = [aws_security_group.eks-master.id]
  }

  ingress {
    description = "Allow cluster master to access cluster nodes"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = [aws_security_group.eks-master.id]
  }

  ingress {
    description = "Allow pods communicate each other"
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.base_tags, { "Name" = "${local.base_name}-eks-node-sg" })
}
