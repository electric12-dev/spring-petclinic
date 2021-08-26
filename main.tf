provider "aws" {
  profile = var.profile
  region  = var.region-master
  alias   = "region-master"
}

#Create VPC in vpc_east-2
resource "aws_vpc" "vpc_east-2" {
  provider             = aws.region-master
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "jenkins"
  }

}


#Create IGW in vpc_east-2
resource "aws_internet_gateway" "igw" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_east-2.id
}

#Create route table in vpc_east-2
resource "aws_route_table" "internet_route" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_east-2.id
  route {
    cidr_block = var.external_ip
    gateway_id = aws_internet_gateway.igw.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Region-RT"
  }
}

#Overwrite default route table of VPC(Master) with our route table entries
resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  provider       = aws.region-master
  vpc_id         = aws_vpc.vpc_east-2.id
  route_table_id = aws_route_table.internet_route.id
}
#Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region-master
  state    = "available"
}

#Create subnet in vpc_east-2
resource "aws_subnet" "subnet" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_east-2.id
  cidr_block        = var.cidr_sub
}

#Create SG for allowing TCP/8080 from * and TCP/22 from your IP in vpc_east-2
resource "aws_security_group" "jenkins-sg" {
  provider    = aws.region-master
  name        = "jenkins-sg"
  description = "Allow TCP/8080 8081 & TCP/22"
  vpc_id      = aws_vpc.vpc_east-2.id
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "allow anyone on port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "allow anyone on port 8081"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}