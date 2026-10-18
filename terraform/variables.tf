variable "project_name" {
  description = "Name used for AWS resource naming"
  type        = string
  default     = "ecommerce-microservices"

}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}


variable "availability_zone" {
  description = "Availability zone to deploy resources"
  type        = string
  default     = "ap-south-1a"
}

variable "instance_type" {
  description = "EC2 instance type for the ecommerce Docker host"
  type        = string
  default     = "t3.medium"
}