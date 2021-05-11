provider "aws" {
    region      = "${var.region}"
    access_key  = "${var.access_key}"
    secret_key  = "${var.secret_key}"
    #version    = "~> 3.0"
}
