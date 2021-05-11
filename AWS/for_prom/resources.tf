resource "aws_vpc" "prom_vpc" {
    cidr_block = "${var.my_cidr}"

    tags = {
        Name = "prom_vpc"
    }
}

resource "aws_subnet" "prom_subnet" {
    count = 2
    cidr_block          = "${cidrsubnet(var.my_cidr,8,count.index)}"
    availability_zone   = data.aws_availability_zones.azs.names[count.index]
    vpc_id              = "${aws_vpc.prom_vpc.id}"
    map_public_ip_on_launch = true
    tags = {
        Name    = "prom_subnet"
    }
}
resource "aws_internet_gateway" "prom_ig" {
    vpc_id = "${aws_vpc.prom_vpc.id}"

    tags = {
        Name    = "prom_ig"
    }
}

resource "aws_route_table" "prom_routetable" {
    vpc_id  = "${aws_vpc.prom_vpc.id}"

    tags = {
        Name    = "prom_routetable"
    }
}

resource "aws_route_table_association" "prom_association_route" {
    
    subnet_id       = "${aws_subnet.prom_subnet[0].id}"
    route_table_id  = "${aws_route_table.prom_routetable.id}"

    
}

resource "aws_route" "prom_route" {
    route_table_id               = "${aws_route_table.prom_routetable.id}"
    destination_cidr_block        = "0.0.0.0/0"
    gateway_id                   = "${aws_internet_gateway.prom_ig.id}"

}

resource "aws_security_group" "prom_security" {
    name            = "prom_security"
    description     = "for prometheus , node_exporter and alert_manager"
    vpc_id          = "${aws_vpc.prom_vpc.id}"

    ingress {
        description = "for prometheus"
        from_port   = 9090
        to_port     = 9090
        protocol    = "tcp"
        cidr_blocks  = [aws_vpc.prom_vpc.cidr_block]
    }

    ingress {
        description = "for node_exporter"
        from_port   = 9100
        to_port     = 9100
        protocol    = "tcp"
        cidr_blocks = [aws_vpc.prom_vpc.cidr_block]
    }

    ingress {
        description = "for alert_manager"
        from_port   = 9093
        to_port     = 9093
        protocol    = "tcp"
        cidr_blocks  = [aws_vpc.prom_vpc.cidr_block]
    }

    egress {
         from_port   = 0
         to_port     = 0
         protocol    = "-1"
         cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "prom_instance" {
    count = 1
    ami             = "ami-0447a12f28fddb066"
    instance_type   = "t2.micro"
    subnet_id       = "${aws_subnet.prom_subnet[0].id}"
    key_name        = "myfirstkey"
    user_data = <<EOF
		#! /bin/bash 
        wget https://github.com/prometheus/prometheus/releases/download/v2.19.0/prometheus-2.19.0.linux-amd64.tar.gz
        tar xvfz prometheus-2.19.0.linux-amd64.tar.gz

        sudo cp prometheus-2.19.0.linux-amd64/prometheus /usr/local/bin
        sudo cp prometheus-2.19.0.linux-amd64/promtool /usr/local/bin/
        sudo cp -r prometheus-2.19.0.linux-amd64/consoles /etc/prometheus
        sudo cp -r prometheus-2.19.0.linux-amd64/console_libraries /etc/prometheus

        sudo cp prometheus-2.19.0.linux-amd64/promtool /usr/local/bin/
        rm -rf prometheus-2.19.0.linux-amd64.tar.gz 
        
	EOF

    depends_on = [aws_internet_gateway.prom_ig]
    tags = {
        Name    = "prom_instance"
    }
}