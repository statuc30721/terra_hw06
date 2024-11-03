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

variable instance_type {
  description = "Identify instamce type to be used for virtual machine."
}

variable "public_key_location" {
  description = "Pass path to the public key to be used to authenticate with a VM instance."
  
}

variable "private_key_location" {
  description = "Pass path to the private key to be used to authenticate with a VM instance."
  
}

#----------------------------------------------------------------#
# 
# Virtual Private Cloud and Network Setup

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

#----------------------------------------------------------------#
# 
# Create an AWS EC2 Virtual Machine Instance. 

# Retrieve the latest AMI

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]

  }
}

output "aws-ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

output "ec2-public_ip" {
  value = aws_instance.myapp-server.public_ip
}

# Identify VPC, network and security group for Linux virtual machine.

resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = file(var.public_key_location)
  
}
resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true

# Identify the name of the SSH key pair to be associated with your linux VM
# NOTE: This SSH key requires a public and private key pair that you have access to.
#
# You must provide the full path to the public and private key pair you intend to use.
# For example a user named joe on a linux system would typically be /home/joe/.ssh/id_rsa.pub 
# for their public key and /home/joe/.ssh/id_rsa for the private key. 
  key_name = aws_key_pair.ssh-key.key_name

#----------------------------------------------------------------#
# Install software on the Amazon EC2 Instance.

user_data = file("entry-script.sh")

user_data_replace_on_change = true



tags = {
    Name: "${var.env_prefix}-server"
  }
}





