variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "ap-south-1"
}

variable "ami_id" {
    type = "map"
    default = {
        us-east-1   = "ami-0a9d27a9f4f5c0efc"
        ap-south-1  = "ami-08f63db601b82ff5f"
    }
}
