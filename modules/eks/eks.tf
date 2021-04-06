resource "aws_eks_cluster" "dev_cluster" {
  name = var.cluster_name
  role_arn = ""
  vpc_config {
    subnet_ids = []
  }
}

output "" {
  value = ""
}