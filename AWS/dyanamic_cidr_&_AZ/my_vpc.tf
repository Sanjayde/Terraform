resource "aws_vpc" "main_sub" {
    cidr_block  = "${var.my_cidr}"
    instance_tenancy    = "default"

    tags = {
        Name = "new_vpc_here"
    }
}

resource "aws_subnet" "main_sub" {
    count   = "${length(data.aws_availability_zones.azs.names)}"
    availability_zone = data.aws_availability_zones.azs.names[count.index]
    vpc_id  = "${aws_vpc.main_sub.id}"
    cidr_block  = "${cidrsubnet(var.my_cidr,8,count.index)}"

    tags = {
        Name  = "new_subnet- ${count.index}"
    }
}