#!/bin/bash
# Requirements:
# terraform https://www.terraform.io/downloads.html
# jq https://stedolan.github.io/jq/download/

#preflight checks
if ! command -v terraform &> /dev/null
then
  echo "terraform is not installed.  Please install the binary.  Script will now exit"
  exit
fi

if ! command -v jq &> /dev/null
then
  echo "jq is not installed.  Please install the binary.  Script will now exit"
  exit
fi

if grep -q CHANGEME vars.tf
then
  echo "Please change the variables in vars.tf.  Script will now exit"
  exit
fi

#the fun stuff
terraform init
terraform plan -out terraform-plan.out
terraform apply terraform-plan.out

#IP of public instance from terraform
PUBLIC_IP=$(jq -r '.resources[] | select((.type=="aws_instance") and (.name=="public-front")) | .instances[] | .attributes | .public_ip' < terraform.tfstate)

echo "The public instance IP is at ${PUBLIC_IP}.  Please use this for nomad configuration"
echo ${PUBLIC_IP} > public_ip.txt
