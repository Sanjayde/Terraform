resource "aws_instance" "check3" {
    ami             = "${var.ami_id}"
    instance_type   = "${var.inst_type}"
    subnet_id       = "${var.sub_id}"
    key_name        = "myfirstkey"

    user_data = data.template_file.init.rendered

    tags = {
        Name = "fortemp"
    }
}