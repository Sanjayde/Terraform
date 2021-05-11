/*terraform {
    required_version = ">=0.11.8"
}
provider "vault" {
    address = "http://127.0.0.1:8200"
}
data "vault_aws_access_credentials" "aws_creds" {
    backend = "aws"
    role = "myrole"
}
*/
provider "aws" {
   // access_key  =   "${data.vault_aws_access_credentials.aws_creds.access_key}"
    //secret_key  =   "${data.vault_aws_access_credentials.aws_creds.secret_key}"
    region      =   "ap-south-1"
}

terraform {
  backend "consul" {
    address = "http://127.0.0.1:8500"
    path    = "tf/state"
  }
}

locals {
  rules = [{
    description = "allow http port for all",
    port = 80,
    cidr_blocks = ["0.0.0.0/0"],
  },{
    description = "allow ssh for all",
    port = 22,
    cidr_blocks = ["0.0.0.0/0"],
  }]
}
/*resource "aws_security_group" "vault_sg" {
  name        = "vault"
  description = "vault"

  dynamic "ingress" {
    for_each = local.rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  tags  = {
      Name = "vault_sg"
  }
}*/
resource "aws_instance" "vault_inst" {
    ami = "ami-08f63db601b82ff5f"
    instance_type = "t2.micro"
    subnet_id = "subnet-05a9ffd7b7df35128"
    key_name    = "acceptor"
    //security_groups = [aws_security_group.vault_sg.id]

    tags    =   {
        Name    = "vault_inst"
    }
}