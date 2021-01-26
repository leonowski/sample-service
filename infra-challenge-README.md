infra-challenge

Instructions:

This is split into 2 parts.  The first part sets up the infrastructure using terraform.  

1.  Fill out the vars in vars.tf

2.  Make sure you have terraform and jq binaries in your PATH

3.  In the terraform dir, `chmod +x ./terraform_setup.sh` and then run it from inside the directory `./terraform_setup.sh`


At the end of the process, it will report the public IP of the public facing instance.  It will also write it to a text file named `public_ip.txt`.


The second part uses nomad for deployment.  The requirements are the Makefile, the nomad job template, and the nomad binary (https://www.nomadproject.io/downloads) installed in your PATH.

For nomad to work, these env vars must be exported:

`NOMAD_HTTP_AUTH="username:password"` (username and password provided by leonowski)

`NOMAD_HTTP_AUTH=http://PUBLIC_IP:8675` (the public IP is the one reported at the end of terraform_setup or in terraform/public_ip.txt)  


Once all those pieces are in place, you can use make to build and deploy.  Examples:

*To build with the tag latest (the default tag) and deploy

`make build-and-deploy`

*To build with the tag "version2" and deploy

`TAG=version2 make build-and-deploy`

*To deploy an existing tag in repo without building

`TAG=sometag make deploy-tag-only`

*To build a local version with a tag and without pushing to repo

`TAG=sometag make build`

Note:  The default repo is on dockerhub at leonowski/sample-service .  The repo needs to be writeable by the user and publicly accesible.  
