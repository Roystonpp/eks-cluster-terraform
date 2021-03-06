provider "aws" {
  region = "eu-west-1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  load_config_file       = false
  version                = "~>1.11"
}

locals {
  cluster_name = "my-cluster"
}

module "vpc" {
  source               = "../modules/vpc"

  name                 = "k8-vpc"
  vpc_cidr_block       = "172.16.0.0/16"
  public_subnets       = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  private_subnets      = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  public_subnet_tags   = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source = "../modules/eks"

  cluster_name    = local.cluster_name
  cluster_version = "1.17"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  endpoint_private_access = false
  endpoint_public_access  = true
}

module "worker-sg" {
  source = "../modules/worker-sg"

  name_prefix = "worker_group_sg"
  vpc_id      = module.vpc.vpc_id
}