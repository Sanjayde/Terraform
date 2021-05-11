resource "aws_instance" "check2" {
    
    count           = "${length(var.inst_name)}"
    instance_type   = "${var.inst_type}"
    subnet_id       = "${var.sub_id}"
    ami             = "${var.ami}"
    
    tags = {
        Name = var.inst_name
    }
}

