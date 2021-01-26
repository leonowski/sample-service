resource "aws_key_pair" "noel-east" {
  key_name   = "noel-east"
  public_key = file(var.PUBLIC_KEY)
}

resource "aws_instance" "public-front" {
    #aws linux 2 SSD
    ami = "ami-0be2609ba883822ec"
    instance_type = "t2.micro"
    network_interface {
      network_interface_id = aws_network_interface.static-public-front.id
      device_index         = 0
    }
    # VPC
    #subnet_id = aws_subnet.main-public.id
    #vpc_security_group_ids = [aws_security_group.public-sg.id]
    key_name = aws_key_pair.noel-east.id
    provisioner "file" {
        source = "nginx.nomad.job"
        destination = "/home/ec2-user/nginx.nomad.job"
    }
    provisioner "file" {
        source = "bootstrap.sh"
        destination = "/tmp/bootstrap.sh"
    }
    provisioner "file" {
        source = "nomad.conf.public"
        destination = "/tmp/nomad.conf"
    }
    provisioner "file" {
        source = "nomad.service"
        destination = "/tmp/nomad.service"
    }
    provisioner "file" {
        source = "nginx.conf"
        destination = "/tmp/nginx.conf"
    }
    provisioner "file" {
        source = ".htpasswd"
        destination = "/tmp/.htpasswd"
    }
    provisioner "remote-exec" {
        inline = [
             "sudo chmod +x /tmp/bootstrap.sh",
             "sudo bash -c '/tmp/bootstrap.sh'"
        ]
    }
    connection {
        type = "ssh"
        host = self.public_ip
        user = "ec2-user"
        private_key = file(var.PRIVATE_KEY)
    }
}

resource "aws_instance" "private-back" {
    #aws linux 2 SSD
    ami = "ami-0be2609ba883822ec"
    instance_type = "t2.micro"
    network_interface {
      network_interface_id = aws_network_interface.static-private-back.id
      device_index         = 0
    }
    key_name = aws_key_pair.noel-east.id
    provisioner "file" {
        source = "bootstrap.sh"
        destination = "/tmp/bootstrap.sh"
    }
    provisioner "file" {
        source = "nomad.conf.private"
        destination = "/tmp/nomad.conf"
    }
    provisioner "file" {
        source = "nomad.service"
        destination = "/tmp/nomad.service"
    }
    provisioner "remote-exec" {
        inline = [
             "sudo chmod +x /tmp/bootstrap.sh",
             "sudo bash -c '/tmp/bootstrap.sh'"
        ]
    }
    connection {
        type = "ssh"
        bastion_host = aws_instance.public-front.public_ip
        host = "172.32.2.20"
        user = "ec2-user"
        private_key = file(var.PRIVATE_KEY)
    }
}
