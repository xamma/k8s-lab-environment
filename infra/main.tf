data "aws_region" "current" {}

locals {
  amis = {
    "us-east-1" = "ami-06878d265978313ca"
    "eu-central-1" = "ami-0039da1f3917fa8e3"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "internal-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.internal-route-table.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "private"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${var.pub_ssh_key}"
}

resource "aws_instance" "k8smaster" {
  ami           = local.amis[data.aws_region.current.name]
  instance_type = "${var.instance_size}"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_egress.id, aws_security_group.allow_http.id, aws_security_group.allow_k8s.id]
  key_name = aws_key_pair.deployer.key_name
}

resource "aws_instance" "k8snode" {
  count = 2
  ami           = local.amis[data.aws_region.current.name]
  instance_type = "${var.instance_size}"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_egress.id, aws_security_group.allow_http.id, aws_security_group.allow_k8s.id]
  key_name = aws_key_pair.deployer.key_name
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow inbound traffic from all sources on port 22"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_k8s" {
  name        = "allow_k8s"
  description = "Allow inbound k8s port 6443"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_egress" {
  name = "allow_egress"
  description = "Security Group for outgoing traffic"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }  
}

resource "aws_security_group" "allow_http" {
  name = "allow_http"
  description = "Security Group for http traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }  
}

resource "local_file" "inventory_ini" {
  content = templatefile("${path.module}/templates/hosts.tpl",
    {
      k8smaster = aws_instance.k8smaster.*.public_ip,
      k8snode = aws_instance.k8snode.*.public_ip
    }
  )
  filename = "../config/inventories/inventory.ini"
}

output "give_me_ip" {
  value = [ 
    aws_instance.k8snode.*.public_dns, 
    aws_instance.k8snode.*.public_ip,
    aws_instance.k8smaster.*.public_dns,
    aws_instance.k8smaster.*.public_ip
  ]
}