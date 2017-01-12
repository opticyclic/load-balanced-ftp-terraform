variable "aws_region" {
  description = "AWS region to launch servers."
  default = "us-east-1"
}

variable "instance_name" {
    type = "string"
    description = "Instance Name"
}

variable "aws_amis" {
    description = "AMI to use"
}

variable "instance_type" {
    type = "string"
    description = "EC2 instance type"
}

variable "key_name" {
    type = "string"
    description = "key-name to deploy with"
}

variable "aws_route53_zone_id" {
    type = "string"
    description = "Route53 Zone ID"
}

variable "aws_access_key" {
    type = "string"
    decscription = "Access key"
}

variable "aws_secret_key" {
    type = "string"
    description = "Secret Key"
}

variable "vpc_id" {
    type = "string"
    description = "VPC ID"
}
