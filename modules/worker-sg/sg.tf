resource "aws_security_group" "worker_sg" {
  name_prefix = var.name_prefix
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "172.16.1.0/24",
      "172.16.2.0/24",
      "172.16.3.0/24"
    ]
  }
}