resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    environment = "dev"
    name        = var.name
  }
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnets" {
  value = var.private_subnets
}