provider "aws" {
    region = var.aws_region
  
}

# Variable aws_region is used to provide a default
# AWS region. You can modify this file directly or 
# for portability put this in a terraform variable file.

variable "aws_region" {
    description = "AWS region"
    type = string
    default = "us-east-1"
  
}

# This provides the CIDR blocks for VPC and subnets.
# I use a variable file versus command line to make it easier to 
# deploy. 

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
}

variable "subnet_cidr_block" {
  
}

# The default value can be overriden in a variable file.

variable "avail_zone" {
    description = "AWS region availability zone"
    type = string
    default = "us-east-1a"
  
}

variable env_prefix {
  description = "Use to identify for deployment."
}

# Create a Virtual Private Cloud. 
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

# Create a subnet within the Virtual Private Cloud. 
# Note that the name gets overridden if variables are provided
# from a terraform tfvars file or via command line.

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
      Name: "${var.env_prefix}-subnet-1"
    }
  
}

