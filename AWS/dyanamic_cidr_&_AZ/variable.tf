variable "my_cidr" {
    default     = "192.10.0.0/16"
}

data "aws_availability_zones" "azs" {}