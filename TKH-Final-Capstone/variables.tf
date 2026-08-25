variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for resources"
}

variable "my_ip" {
  type        = string
  default     = "108.14.201.176/32"
  description = "Home IP address for SSH access"
}