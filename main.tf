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

variable "cidr_blocks" {
  description = "cidr blocks and name tags for vpc and subnets"
  type = list(object({
    cidr_block = string
    name = string 
  }))
}

# The default value can be overriden in a variable file.

variable "avail_zone" {
    description = "AWS region availability zone"
    type = string
    default = "us-east-1a"
  
}

# Create a Virtual Private Cloud with name myapp-vpc. 
# Note that this gets overridden if variables are provided
# from a terraform tfvars file or via command line.

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.cidr_blocks[0].cidr_block
  tags = {
    Name: var.cidr_blocks[0].name
  }
}

# Create a subnet within the Virtual Private Cloud. 
# Note that the name gets overridden if variables are provided
# from a terraform tfvars file or via command line.

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.cidr_blocks[1].cidr_block
    availability_zone = var.avail_zone
    tags = {
      Name: var.cidr_blocks[1].name
    }
  
}

