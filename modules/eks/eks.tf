resource "aws_eks_cluster" "dev_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = "${var.subnets}"

    # Indicates if Amazon EKS private API server endpoint is enabled (good for bastion or vpn connection)
    endpoint_private_access = var.endpoint_private_access
    # Indicates if Amazon EKS public API server endpoint is enabled
    endpoint_public_access  = var.endpoint_public_access
  }

  # Ensures permissions are created before EKS cluster creation
  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-attachment
  ]
}

# The role that Amazon EKS will use to create AWS resources for the Kubernetes cluster
resource "aws_iam_role" "eks_cluster_role" {
  name               = "eks-cluster-role"
  assume_role_policy = <<POLICY
{
"Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

  # The role the policy should be applied to
  role       = aws_iam_role.eks_cluster_role.name
}