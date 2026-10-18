# Security Groups for the application
resource "aws_security_group" "ecommerce" {
  name_prefix = "${var.project_name}-sg"
  description = "Security group for the ecommerce application"
  vpc_id      = aws_vpc.ecommerce.id
  tags = {
    Name = "${var.project_name}-security-group"
  }
}
# Allow public HTTP traffic to Nginx
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.ecommerce.id
  description       = "Allow HTTP traffic"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

#Allow Outbound traffic for downloads
resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.ecommerce.id
  description       = "Allow outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
