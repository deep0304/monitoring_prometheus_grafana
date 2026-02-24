resource "aws_vpc" "server_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "server_vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.server_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.server_vpc.id

  tags = {
    Name = "server_vpc_igw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.server_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "server_vpc_route_table"
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "allow_inbound" {
  name   = "allow_inbound"
  vpc_id = aws_vpc.server_vpc.id

  tags = {
    Name = "allow_inbound"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.allow_inbound.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "prometheus" {
  security_group_id = aws_security_group.allow_inbound.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 9090
  to_port           = 9090
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "node_exporter" {
  security_group_id = aws_security_group.allow_inbound.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 9100
  to_port           = 9100
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "grafana" {
  security_group_id = aws_security_group.allow_inbound.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3000
  to_port           = 3000
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.allow_inbound.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22    
  ip_protocol       = "tcp"
}


resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.allow_inbound.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

data "aws_ami" "nginx_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["nginxEnabled"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "nginx_server" {
  ami                         = data.aws_ami.nginx_ami.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.allow_inbound.id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/script.sh")
  key_name   = "network-devops-keypair"

  tags = {
    Name = "nginx_server"
  }
}

resource "aws_instance" "server_with_prometheus" {
  ami                         = data.aws_ami.nginx_ami.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.allow_inbound.id]
  associate_public_ip_address = true
  key_name   = "network-devops-keypair"
  user_data                   = file("${path.module}/script-prom_grafana.sh")

  tags = {
    Name = "server_with_prometheus"
  }
}