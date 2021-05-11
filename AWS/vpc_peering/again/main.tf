resource "aws_vpc_peering_connection" "foo" {
  
  peer_vpc_id   = "vpc-0bab6883e7f3333d1"
  vpc_id        = "vpc-08c826cf5f1bf1fda"

  
}