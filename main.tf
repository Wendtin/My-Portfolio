provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "sabotaged_sg" {
  name        = "tlab7-exposed-sg"
  description = "A dangerously exposed security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "SSH access from home IP only"
    cidr_blocks = ["108.14.201.176/32"]
  }
}