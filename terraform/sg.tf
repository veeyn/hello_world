resource "aws_security_group" "ALB_sg" {
  name        = "ALB-sg"
  description = "Inbound traffic port 80 from anywhere"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ContainerFromALB_sg" {
  name        = "ContainerFromALB-sg"
  description = "Inbound traffic from ALB"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    security_groups = [aws_security_group.ALB_sg.id]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ECREndpoint_sg" {
  name        = "ECREndpoint-sg"
  description = "Inbound traffic for ECR VPC endpoint"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.ContainerFromALB_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
