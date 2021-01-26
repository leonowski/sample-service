//the main VPC

resource "aws_vpc" "main-vpc" {
    cidr_block = "172.32.0.0/16"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    instance_tenancy = "default"

}

// public facing subnet
resource "aws_subnet" "main-public" {
    vpc_id = aws_vpc.main-vpc.id
    cidr_block = "172.32.1.0/24"
    map_public_ip_on_launch = "true"
}

// private subnet no incoming internet
resource "aws_subnet" "main-private" {
    vpc_id = aws_vpc.main-vpc.id
    cidr_block = "172.32.2.0/24"
    map_public_ip_on_launch = "false"
}

//main igw for public subnet
resource "aws_internet_gateway" "main-igw" {
    vpc_id = aws_vpc.main-vpc.id
}

//elastic IP for private subnet
resource "aws_eip" "private-eip" {
  vpc      = true
}

// nat gateway for private subnet
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.private-eip.id
  subnet_id     = aws_subnet.main-public.id
}

//route tables
resource "aws_route_table" "public-route" {
    vpc_id = aws_vpc.main-vpc.id
        route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main-igw.id
    }
}
resource "aws_route_table" "private-route" {
    vpc_id = aws_vpc.main-vpc.id
        route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.natgw.id
    }
}

//route associations
resource "aws_route_table_association" "public-association"{
    subnet_id = aws_subnet.main-public.id
    route_table_id = aws_route_table.public-route.id
}

resource "aws_route_table_association" "private-association"{
    subnet_id = aws_subnet.main-private.id
    route_table_id = aws_route_table.private-route.id
}

//security groups
resource "aws_security_group" "public-sg" {
    vpc_id = aws_vpc.main-vpc.id

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 8675
        to_port = 8675
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["172.32.0.0/16"]
    }

}
resource "aws_security_group" "private-sg" {
    vpc_id = aws_vpc.main-vpc.id

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["172.32.0.0/16"]
    }

}
//static private IPs
resource "aws_network_interface" "static-public-front" {
  subnet_id       = aws_subnet.main-public.id
  private_ips     = ["172.32.1.10"]
  security_groups = [aws_security_group.public-sg.id]
}
  resource "aws_network_interface" "static-private-back" {
    subnet_id       = aws_subnet.main-private.id
    private_ips     = ["172.32.2.20"]
    security_groups = [aws_security_group.private-sg.id]
    depends_on      = [aws_network_interface.static-public-front]

}
