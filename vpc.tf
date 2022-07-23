provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region = "${var.vpc_region}"
}



# Define a vpc
resource "aws_vpc" "vpc_name" {
  cidr_block = "${var.vpc_cidr_block}"
  tags = {
    Name = "${var.vpc_name}"
  }
}



# Internet gateway for the public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc_name.id}"
  tags = {
    Name = "igw"
  }
}

# Public subnet
resource "aws_subnet" "public1" {
  vpc_id = "${aws_vpc.vpc_name.id}"
  cidr_block = "${var.vpc_public_subnet_1_cidr}"
  availability_zone = "${lookup(var.availability_zone, var.vpc_region)}"
  map_public_ip_on_launch = true
  tags = {
    Name = "public1"
  }
}

# Private subnet
resource "aws_subnet" "private1" {
  vpc_id = "${aws_vpc.vpc_name.id}"
  cidr_block = "${var.vpc_private_subnet_1_cidr}"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private1"
  }
}

# Routing table for public subnet
resource "aws_route_table" "public1_rt" {
  vpc_id = "${aws_vpc.vpc_name.id}"
  route {
    cidr_block = ""0.0.0.0/0""
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags = {
    Name = "public1_rt"
  }
}


# Associate the routing table to public subnet
resource "aws_route_table_association" "public1_rt_assn" {
  subnet_id = "${aws_subnet.public1.id}"
  route_table_id = "${aws_route_table.public1_rt.id}"
}

resource "aws_route_table_association" "public2_rt_assn" {
  subnet_id = "${aws_subnet.public2.id}"
  route_table_id = "${aws_route_table.public2_rt.id}"
}

resource "aws_instance" "example" {
  ami           = "${var.ami_name}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public1.id}"
  vpc_security_group_ids = [ "${aws_security_group.vpc_public_sg.id}" ]
  key_name = "${var.sshkeyname}"

  tags = {
    Name = "${var.ec2name}"
  }

  
}

resource "null_resource" "example" {
  
  provisioner "file" {
    connection {
      host = aws_instance.example.public_ip
      user = "ec2-user"
      private_key = file("${var.sshkeyname}")
    }
    source = "./twitter_analytics.py"
    destination = "/tmp/twitter_analytics.py"
  }
  provisioner "remote-exec" {
    connection {
      host = aws_instance.example.public_ip
      user = "ec2-user"
      private_key = file("${var.sshkeyname}")
    }
    inline = [
      "curl -O https://bootstrap.pypa.io/get-pip.py",
      "python3 get-pip.py --user",
      "cd ~",
      "pip3 install boto3",
      "pip3 install tweepy",
      "cd ..",
      "cd ..",
      "cd etc",
      "python3 /tmp/twitter_analytics.py \\#covid_19"
    ]
  }
}

resource "aws_kinesis_stream" "test_stream" {
  name             = "terraform-kinesis-test"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    Environment = "test"
  }
}

# ECS Instance Security group
resource "aws_security_group" "vpc_public_sg" {
  name = "public_sg"
  description = "public access security group"
  vpc_id = "${aws_vpc.vpc_name.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "${var.vpc_access_from_ip_range}"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = [
      "${var.vpc_public_subnet_1_cidr}"]
  }

  egress {
    # allow all traffic to private SN
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Name = "pubic_sg"
  }
}

resource "aws_security_group" "vpc_private_sg" {
  name = "demo_private_sg"
  description = "demo security group to access private ports"
  vpc_id = "${aws_vpc.vpc_name.id}"

  # allow memcached port within VPC

 ingress {
    from_port = 11211
    to_port = 11211
    protocol = "tcp"
    cidr_blocks = [
      "${var.vpc_public_subnet_1_cidr}"]
  }

  # allow redis port within VPC
  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    cidr_blocks = [
      "${var.vpc_public_subnet_1_cidr}"]
  }

  # allow postgres port within VPC
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [
      "${var.vpc_public_subnet_1_cidr}"]
  }

  # allow mysql port within VPC
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [
      "${var.vpc_public_subnet_1_cidr}"]
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Name = "demo_private_sg"
  }
}

output "vpc_region" {
  value = "${var.vpc_region}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc_name.id}"
}

output "public1_id" {
  value = "${aws_subnet.public1.id}"
}

output "private1_id" {
  value = "${aws_subnet.private1.id}"
}

output "vpc_public_sg_id" {
  value = "${aws_security_group.vpc_public_sg.id}"
}

output "vpc_private_sg_id" {
  value = "${aws_security_group.vpc_private_sg.id}"
}
