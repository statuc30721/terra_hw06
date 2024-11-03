provider "aws" {
    region = var.aws_region
  
}

#----------------------------------------------------------------#
#
# Variables

# Variable aws_region is used to provide a default
# AWS region. You can modify this file directly or 
# for portability put this in a terraform variable file.

variable "aws_region" {
    description = "AWS region"
    type = string
    default = "us-east-1"
  
}

# This provides the CIDR blocks for VPC and subnets.

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
}

# This variable sets the subnet within the CIDR block. 
variable "subnet_cidr_block" {
  
}

# Set AWS availaibility zone for the VPC. 
variable "avail_zone" {
    description = "AWS region availability zone"
    type = string
    default = "us-east-1a"
  
}

# Identify the virtual environment. For example Development,
# Test, etc. 
variable env_prefix {
  description = "Use to identify for deployment environment."
}

#----------------------------------------------------------------#
# 
# Resources

# Setup additional routes within the VPC. 

resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
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

