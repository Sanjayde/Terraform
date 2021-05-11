resource "aws_instance" "check1" {
    ami             = "${lookup(var.ami_id,var.region)}"
    instance_type   = "t2.micro"
    subnet_id       = "subnet-05a9ffd7b7df35128"
    #vpc_security_group_ids = ""
}

