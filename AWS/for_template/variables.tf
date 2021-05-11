variable "access_key" {}
variable "secret_key" {}

variable "ami_id" {
    default = "ami-08f63db601b82ff5f"
}

variable "inst_type" {
    default = "t2.micro"
}

variable "sub_id" {
    default = "subnet-05a9ffd7b7df35128"
}