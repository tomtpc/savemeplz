terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
    profile = "default"
    region = "ca-central-1"
}

resource "aws_vpc" "thanhhv18_vpc" {
    cidr_block = "192.168.0.0/16"
#   instance_tenancy = "default"
    tags = {
      Name = "thanhhv18_vpc"
    }
}

resource "aws_subnet" "thanhhv18_public_subnet_no1" {
    vpc_id = aws_vpc.thanhhv18_vpc.id
    cidr_block = "192.168.10.0/24"
    availability_zone = "ca-central-1a"
    tags = {
      Name = "thanhhv18_public_subnet"
    }
}

resource "aws_subnet" "thanhhv18_public_subnet_no2" {
    vpc_id = aws_vpc.thanhhv18_vpc.id
    cidr_block = "192.168.20.0/24"
    availability_zone = "ca-central-1a"
    tags = {
      Name = "thanhhv18_public_subnet"
    }
}

resource "aws_internet_gateway" "thanhhv18_igw" {
    vpc_id = aws_vpc.thanhhv18_vpc.id
    tags = {
      Name = "thanhhv18_igw"
    }
}

resource "aws_route_table" "thanhhv18_public_route_table" {
    vpc_id = aws_vpc.thanhhv18_vpc.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.thanhhv18_igw.id
    }
    tags = {
      Name = "thanhhv18_public_route_table"
    }
}

resource "aws_route_table_association" "thanhhv18_public_route_table_association_no1" {
    subnet_id = aws_subnet.thanhhv18_public_subnet_no1.id
    route_table_id = aws_route_table.thanhhv18_public_route_table.id
}

resource "aws_route_table_association" "thanhhv18_public_route_table_association_no2" {
    subnet_id = aws_subnet.thanhhv18_public_subnet_no2.id
    route_table_id = aws_route_table.thanhhv18_public_route_table.id
}

resource "aws_security_group" "thanhhv18_public_security_group" {
    name = "thanhhv18_public_security_group"
    description = "Allow inbound traffic from the Internet"
    vpc_id = aws_vpc.thanhhv18_vpc.id
    ingress {
      description = "Allow SSH"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      description = "Allow HTTP"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      description = "Allow HTTPS"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "thanhhv18_public_security_group"
    }
}


resource "aws_key_pair" "thanhhv18_key_pair" {
    key_name = "thanhhv18_canada_home"
    public_key = file("../thanhhv18_canada_home.pub")
}

resource "aws_instance" "thanhhv18_jenkins_server" {
    ami = "ami-0b6937ac543fe96d7"
    instance_type = "t3.medium"
    key_name = aws_key_pair.thanhhv18_key_pair.key_name
    subnet_id = aws_subnet.thanhhv18_public_subnet_no1
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.thanhhv18_public_security_group.id]
    tags = {
      Name = "thanhhv18_jenkins_server"
    }
}

resource "aws_instance" "thanhhv18_jenkins_agent" {
    ami = "ami-0b6937ac543fe96d7"
    instance_type = "t3.medium"
    key_name = aws_key_pair.thanhhv18_key_pair.key_name
    subnet_id = aws_subnet.thanhhv18_public_subnet_no2.id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.thanhhv18_public_security_group.id]
    tags = {
      Name = "thanhhv18_jenkins_agent"
    }
}

resource "aws_instance" "thanhhv18_web_server" {
    ami = "ami-0b6937ac543fe96d7"
    instance_type = "t3.medium"
    key_name = aws_key_pair.thanhhv18_key_pair.key_name
    subnet_id = aws_subnet.thanhhv18_public_subnet_no2.id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.thanhhv18_public_security_group.id]
    tags = {
      Name = "thanhhv18_web_server"
    }
}

output "thanhhv18_jenkins_server_public_ip" {
    value = aws_instance.thanhhv18_jenkins_server.public_ip
    description = "value of thanhhv18_jenkins_server_public_ip"
}

output "thanhhv18_jenkins_agent_public_ip" {
    value = aws_instance.thanhhv18_jenkins_agent.public_ip
    description = "value of thanhhv18_jenkins_agent_public_ip"
}

output "thanhhv18_jenkins_agent_private_ip" {
    value = aws_instance.thanhhv18_jenkins_agent.private_ip
    description = "value of thanhhv18_jenkins_agent_private_ip"
}

output "thanhhv18_web_server_public_ip" {
    value = aws_instance.thanhhv18_web_server.public_ip
    description = "value of thanhhv18_web_server_public_ip"
}

output "thanhhv18_web_server_private_ip" {
    value = aws_instance.thanhhv18_web_server.private_ip
    description = "value of thanhhv18_web_server_private_ip"
}