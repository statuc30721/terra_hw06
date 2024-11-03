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

variable my_ip {
  description = "Identify source IP address allowed to remotely access the virtual machine."
}
# 
#----------------------------------------------------------------#
# 
# Resources

# Create a Virtual Private Cloud. 
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

# Create a subnet within the Virtual Private Cloud. 

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
      Name: "${var.env_prefix}-subnet-1"
    }
  }

# Add an internet gateway to the VPC. 

resource "aws_internet_gateway" "myapp-igw" {
   vpc_id = aws_vpc.myapp-vpc.id
   tags = {
     Name: "${var.env_prefix}-igw"
   }
}


# Setup default route table within the VPC environment. 

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-main-rtb"
  }
}

#----------------------------------------------------------------#
#
# Security Groups

resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.myapp-vpc.id  

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name: "${var.env_prefix}-default-sg"
  }

}