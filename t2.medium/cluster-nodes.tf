provider "aws" {
  region = "us-west-2"
}

data "aws_vpc" "home-vpc" {
  id = "your-vpc-id"
}

data "aws_subnet" "border_subnet" {
  id    = "your-border-subnet-id"
  vpc_id = data.aws_vpc.home-vpc.id
}

data "aws_security_group" "border_sg" {
  id    = "your-bg-security-group-id"
  vpc_id = data.aws_vpc.home-vpc.id
}

resource "aws_instance" "control-node" {
  ami           = "your-preffered-ami(ami-008fe2fc65df48dac)"
  instance_type = "t2.medium"
  key_name      = "your-key-name-pair"

  vpc_security_group_ids = [data.aws_security_group.border_sg.id]
  subnet_id              = data.aws_subnet.border_subnet.id

  private_ip = "10.0.0.101"

  associate_public_ip_address = true  # Assign public IP
  tags = {
    Name = "control-node"
  }
}

resource "aws_instance" "m-nodes" {
  count         = 3
  ami           = "your-preffered-ami(ami-008fe2fc65df48dac)"
  instance_type = "t2.medium"
  key_name      = "id_rsa_pub"

  vpc_security_group_ids = [data.aws_security_group.border_sg.id]
  subnet_id              = data.aws_subnet.border_subnet.id

  private_ip = cidrhost(data.aws_subnet.border_subnet.cidr_block, 201 + count.index)

  associate_public_ip_address = true  # Assign public IP
  tags = {
    Name = "m-node-${count.index + 1}"
  }
}
