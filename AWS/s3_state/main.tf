provider "aws" {
    region         = "ap-south-1"
    
}

resource "aws_s3_bucket" "my_buck" {
    bucket = "formystate23"
    acl    = "private"

    lifecycle {
        prevent_destroy = true
    }
    versioning {
        enabled = true
    }

    tags = {
        Name        = "my_buck"
    }
} 
resource "aws_dynamodb_table" "forstate" {
    Name    = "for_state_lock"
    hash_key    = "LockID"
    read_capacity   = "8"
    write_capacity  = "8"

    attribute {
        name = "LockID"
        type = "S"
    }

    tags {
        Name    = "StateLock"
    }
}
terraform {
  backend "s3" {
    bucket = "formystate23"
    key = "terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "for_state_lock"
    encrypt = true
  }
}