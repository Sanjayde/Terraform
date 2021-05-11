provider "aws" {
    region      = "${var.region}"
    access_key  = "${var.access_key}"
    secret_key  = "${var.secret_key}"
}

module "mymodule" {
    source           = "github.com/Sanjayde/for_module.git"
    ami              = "ami-08f63db601b82ff5f"
    sub_id           = "subnet-05a9ffd7b7df35128"
    inst_type        = "t2.micro"
    inst_name        = "myname"
}