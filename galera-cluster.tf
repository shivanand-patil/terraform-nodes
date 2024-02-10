provider "aws" {
  region = "us-west-2"
}

data "aws_vpc" "home-vpc" {
  id = "vpc-0cf38ec5430cab510"
}

data "aws_subnet" "border_subnet" {
  id    = "subnet-007296ad4320fedd3"
  vpc_id = data.aws_vpc.home-vpc.id
}

data "aws_security_group" "border_sg" {
  id    = "sg-0802ad77880a7bb81"
  vpc_id = data.aws_vpc.home-vpc.id
}

# resource "aws_instance" "control-node" {
#   ami           = "ami-008fe2fc65df48dac"
#   instance_type = "t2.micro"
#   key_name      = "id_rsa_pub"
#
#   vpc_security_group_ids = [data.aws_security_group.border_sg.id]
#   subnet_id              = data.aws_subnet.border_subnet.id
#
#   private_ip = "10.0.0.101"
#
#   associate_public_ip_address = true  # Assign public IP
#   tags = {
#     Name = "control-node"
#   }
# }


resource "aws_instance" "m-nodes" {
  count         = 2
  ami           = "ami-008fe2fc65df48dac"
  instance_type = "t2.micro"
  key_name      = "id_rsa_pub"

  vpc_security_group_ids = [data.aws_security_group.border_sg.id]
  subnet_id              = data.aws_subnet.border_subnet.id

  private_ip = cidrhost(data.aws_subnet.border_subnet.cidr_block, 201 + count.index)

  associate_public_ip_address = true  # Assign public IP
  tags = {
    Name = "m-node-${count.index + 1}"
  }
}

