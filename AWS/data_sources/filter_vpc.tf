provider "aws" {
    region      = "${var.region}"
    access_key  = "${var.access_key}"
    secret_key  = "${var.secret_key}"
}
data "aws_vpc" "select" {
    filter {
        name = "tag:Name"
        values = ["jk"]
    }
}
output "my_aws_vpc_id" {
    value = "${data.aws_vpc.select.id}"
}