#!/bin/bash
sudo mkdir -p /etc/nomad.conf.d /etc/nginx || true
sudo cp /tmp/nomad.conf /etc/nomad.conf.d/nomad.conf
sudo cp /tmp/nomad.service /lib/systemd/system/nomad.service
sudo cp /tmp/.htpasswd /etc/nginx/.htpasswd || true
sudo cp /tmp/nginx.conf /etc/nginx/nginx.conf || true

#docker install
sudo yum update -y
sudo amazon-linux-extras install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -a -G docker ec2-user

#prepare nomad
wget https://releases.hashicorp.com/nomad/1.0.2/nomad_1.0.2_linux_amd64.zip
unzip nomad_1.0.2_linux_amd64.zip
sudo mv nomad /usr/local/sbin/
sudo systemctl enable nomad
sudo systemctl start nomad

#start frontend nginx via nomad.
bash -c 'sleep 30 && /usr/local/sbin/nomad run /home/ec2-user/nginx.nomad.job 2>/dev/null' || true
