
### GET Account ID of AWS ELB Servive Account
data "aws_elb_service_account" "main" {}

### CREATE BUCKET

resource "aws_s3_bucket" "elb-bucket-0001" {

    bucket = "woclandiner-bucket-0001"
    acl    = "private"

    policy = <<POLICY
{
            "Id": "policy-elb-gitlab-0001",
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": [
                        "s3:PutObject"
                    ],
                    "Effect": "Allow",
                    "Resource": "arn:aws:s3:::woclandiner-bucket-0001/*",
                    "Principal": {
                        "AWS": [
                            "${data.aws_elb_service_account.main.arn}"
                        ]
                    }
                }
            ]
}
POLICY

    tags = {
        Name        = "elb-bucket-0001"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

### CREATE VPC

resource "aws_vpc" "vpc-corp-0001" {

    cidr_block           = var.CIDR01
    instance_tenancy     = var.instancetenancy
    enable_dns_support   = var.dnssupport
    enable_dns_hostnames = var.dnshostnames

    tags = {

        Name        = "vpc-corp-0001"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"

    }

}

### ADD SECONDARY CIDR  

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {

    vpc_id     = aws_vpc.vpc-corp-0001.id
    cidr_block = var.CIDR02

}

### ADD SECURITY GROUP WEB

resource "aws_security_group" "secgrp-web-0001" {

    vpc_id      =    aws_vpc.vpc-corp-0001.id
    name        =    "secgrp-web-0001"
    description =    "WEB SG"

    tags = {
        Name        = "secgrp-web-0001"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

### CREATING RULES FOR SECURITY GROUP WEB

resource "aws_security_group_rule" "rule-in-ssh-0001" {

    security_group_id = aws_security_group.secgrp-web-0001.id
    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "rule-in-http-0001" {

    security_group_id = aws_security_group.secgrp-web-0001.id
    type        = "ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "rule-in-https-0001" {

    security_group_id = aws_security_group.secgrp-web-0001.id
    type        = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "rule-in-icmp-0001" {

    security_group_id = aws_security_group.secgrp-web-0001.id
    type        = "ingress"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "rule-out-http-0001" {

    security_group_id = aws_security_group.secgrp-web-0001.id
    type        = "egress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "rule-out-https-0001" {

    security_group_id = aws_security_group.secgrp-web-0001.id
    type        = "egress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "rule-out-ssh-0001" {

    security_group_id = aws_security_group.secgrp-web-0001.id
    type        = "egress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.destinationdefault]

}

### ADD SECURITY GROUP RDS

resource "aws_security_group" "secgrp-rds-0001" {

    vpc_id       = aws_vpc.vpc-corp-0001.id
    name         = "secgrp-rds-0001"
    description  = "RDS SG"

    tags = {
        Name = "secgrp-rds-0001"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

### CREATING RULE FOR SECURITY GROUP RDS
### IT'S NECESSARY TO USE SOURCE SECURITY GROUP AS SOURCE

resource "aws_security_group_rule" "rule-in-postgre-0001" {

    type        = "ingress"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_group_id = aws_security_group.secgrp-rds-0001.id
    source_security_group_id = aws_security_group.secgrp-mgmt-0001.id

}

### ADD SECURITY GROUP REDIS

resource "aws_security_group" "secgrp-redis-0001" {

    vpc_id       = aws_vpc.vpc-corp-0001.id
    name         = "secgrp-redis-0001"
    description  = "REDIS SG"

    tags = {
        Name = "secgrp-redis-0001"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

### CREATING RULE FOR SECURITY GROUP REDIS
### IT'S NECESSARY TO USE SOURCE SECURITY GROUP AS SOURCE

resource "aws_security_group_rule" "rule-in-redis-0001" {

    type        = "ingress"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_group_id = aws_security_group.secgrp-redis-0001.id
    source_security_group_id = aws_security_group.secgrp-mgmt-0001.id

}

### ADD SECURITY GROUP PRIVATE

resource "aws_security_group" "secgrp-private-0001" {

    vpc_id       = aws_vpc.vpc-corp-0001.id
    name         = "secgrp-private-0001"
    description  = "sg private"

    tags = {
        Name        = "secgrp-private-0001"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

### CREATING RULE FOR SECURITY GROUP PRIVATE
### IT'S NECESSARY TO USE SOURCE SECURITY GROUP AS SOURCE

resource "aws_security_group_rule" "rule-in-ssh-0002" {

    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_group_id = aws_security_group.secgrp-private-0001.id
    source_security_group_id = aws_security_group.secgrp-web-0001.id

}

resource "aws_security_group_rule" "rule-in-http-0002" {

    type        = "ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_group_id = aws_security_group.secgrp-private-0001.id
    source_security_group_id = aws_security_group.secgrp-web-0001.id

}

resource "aws_security_group_rule" "rule-in-https-0002" {

    type        = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_group_id = aws_security_group.secgrp-private-0001.id
    source_security_group_id = aws_security_group.secgrp-web-0001.id

}

resource "aws_security_group_rule" "rule-out-http-0002" {

    security_group_id = aws_security_group.secgrp-private-0001.id
    type        = "egress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "rule-out-https-0002" {

    security_group_id = aws_security_group.secgrp-private-0001.id
    type        = "egress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.destinationdefault]

}

### ADD SECURITY FGT WAN

resource "aws_security_group" "secgrp-fgtwan-0001" {

    vpc_id       = aws_vpc.vpc-corp-0001.id
    name         = "secgrp-fgtwan-0001"
    description  = "SG FGT WAN"

    tags = {
        Name        = "secgrp-fgtwan-0001"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

### CREATING RULE FOR SECURITY GROUP FGT WAN

resource "aws_security_group_rule" "rule-in-https-0004" {

    type        = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_group_id = aws_security_group.secgrp-fgtwan-0001.id
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "rule-in-https-mgmt-0001" {

    type        = "ingress"
    from_port   = 40443
    to_port     = 40443
    protocol    = "tcp"
    security_group_id = aws_security_group.secgrp-fgtwan-0001.id
    cidr_blocks = [var.destinationdefault]

}

### ADD SECURITY GROUP MGMT

resource "aws_security_group" "secgrp-mgmt-0001" {

    vpc_id       = aws_vpc.vpc-corp-0001.id
    name         = "secgrp-mgmt-0001"
    description  = "SG MGMT"

    tags = {
        Name        = "secgrp-mgmt-0001"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

### CREATING RULE FOR SECURITY GROUP MGMT

resource "aws_security_group_rule" "rule-in-ssh-0003" {

    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_group_id = aws_security_group.secgrp-mgmt-0001.id
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "rule-in-rdp-0001" {

    type        = "ingress"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    security_group_id = aws_security_group.secgrp-mgmt-0001.id
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "rule-in-http-0003" {

    type        = "ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_group_id = aws_security_group.secgrp-mgmt-0001.id
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "rule-in-https-0003" {

    type        = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_group_id = aws_security_group.secgrp-mgmt-0001.id
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "rule-out-all-0001" {

    type        = "egress"
    from_port   = -1
    to_port     = -1
    protocol    = "-1"
    security_group_id = aws_security_group.secgrp-mgmt-0001.id
    cidr_blocks = [var.destinationdefault]

}

### CREATE SUBNETS

resource "aws_subnet" "pub-net-01" {

    vpc_id                  = aws_vpc.vpc-corp-0001.id
    cidr_block              = var.externalsubnet01
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone1

    tags = {
        Name        = "pub-net-01"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

resource "aws_subnet" "pub-net-02" {

    vpc_id                  = aws_vpc.vpc-corp-0001.id
    cidr_block              = var.externalsubnet02
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone2

    tags = {
        Name        = "pub-net-02"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

resource "aws_subnet" "pub-net-03" {

    vpc_id                  = aws_vpc.vpc-corp-0001.id
    cidr_block              = var.externalsubnet03
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone3

    tags = {
        Name        = "pub-net-03"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

resource "aws_subnet" "pub-net-04" {

    vpc_id                  = aws_vpc.vpc-corp-0001.id
    cidr_block              = var.externalsubnet04
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone4

    tags = {
        Name        = "pub-net-04"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

resource "aws_subnet" "priv-net-01" {

    vpc_id                  = aws_vpc.vpc-corp-0001.id
    cidr_block              = var.internalsubnet01
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone1

    tags = {
        Name        = "priv-net-01"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

resource "aws_subnet" "priv-net-02" {

    vpc_id                  = aws_vpc.vpc-corp-0001.id
    cidr_block              = var.internalsubnet02
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone2

    tags = {
        Name        = "priv-net-02"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

resource "aws_subnet" "priv-net-03" {

    vpc_id                  = aws_vpc.vpc-corp-0001.id
    cidr_block              = var.internalsubnet03
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone3

    tags = {
        Name        = "priv-net-03"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

resource "aws_subnet" "priv-net-04" {

    vpc_id                  = aws_vpc.vpc-corp-0001.id
    cidr_block              = var.internalsubnet04
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone4

    tags = {
        Name        = "priv-net-04"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

resource "aws_subnet" "mgmt-net-01" {

    vpc_id                  = aws_vpc.vpc-corp-0001.id
    cidr_block              = var.mgmtsubnet01
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone1

    tags = {
        Name        = "mgmt-net-01"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

resource "aws_subnet" "mgmt-net-02" {

    vpc_id                  = aws_vpc.vpc-corp-0001.id
    cidr_block              = var.mgmtsubnet02
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone2

    tags = {
        Name        = "mgmt-net-02"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

resource "aws_subnet" "mgmt-net-03" {

    vpc_id                  = aws_vpc.vpc-corp-0001.id
    cidr_block              = var.mgmtsubnet03
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone3

    tags = {
        Name        = "mgmt-net-03"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

resource "aws_subnet" "mgmt-net-04" {

    vpc_id                  = aws_vpc.vpc-corp-0001.id
    cidr_block              = var.mgmtsubnet04
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone4

    tags = {
        Name        = "mgmt-net-04"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

### CREATE INTERNET GATEWAY

resource "aws_internet_gateway" "int-gw-0001" {

    vpc_id = aws_vpc.vpc-corp-0001.id

    tags = {
        Name        = "int-gw-0001"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

### CREATE ROUTE TABLE

resource "aws_route_table" "rt-public-0001" {

    vpc_id = aws_vpc.vpc-corp-0001.id

    tags = {
        Name        = "rt-public-0001"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

resource "aws_route_table" "rt-private-0001" {

    vpc_id = aws_vpc.vpc-corp-0001.id

    tags = {
        Name        = "rt-private-0001"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }
}

resource "aws_route_table" "rt-mgmt-0001" {

    vpc_id = aws_vpc.vpc-corp-0001.id

    tags = {
        Name        = "rt-mgmt-0002"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }
}

### CREATE ROUTE TO INTERNET

resource "aws_route" "TRF_Internet_Route" {

    route_table_id = aws_route_table.rt-public-0001.id
    destination_cidr_block = var.destinationdefault
    gateway_id = aws_internet_gateway.int-gw-0001.id

}

### CREATE ELASTIC IP

resource "aws_eip" "eip-0001"{

    tags = {
        Name        = "eip-0001"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

resource "aws_eip" "eip-0002"{

    tags = {
        Name        = "eip-0002"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

resource "aws_eip" "eip-0003"{

    tags = {
        Name        = "eip-0003"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

resource "aws_eip" "eip-0004"{

    tags = {
        Name        = "eip-0004"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

### CREATE NAT GATEWAY

resource "aws_nat_gateway" "nat-gw-0001" {
    subnet_id = aws_subnet.pub-net-01.id
    allocation_id = aws_eip.eip-0001.id

    tags = {
        Name        = "nat-gw-0001"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

### CREATE NAT GATEWAY

resource "aws_nat_gateway" "nat-gw-0002" {
    subnet_id = aws_subnet.pub-net-02.id
    allocation_id = aws_eip.eip-0002.id

    tags = {
        Name        = "nat-gw-0002"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

### CREATE ROUTE TO NAT GATEWAY FROM INTERNAL NETWORK

resource "aws_route" "TRF_Nat_Route_Int_Net_01" {

    route_table_id = aws_route_table.rt-private-0001.id
    destination_cidr_block = var.destinationdefault
    nat_gateway_id = aws_nat_gateway.nat-gw-0001.id

}

### CREATE ROUTE TO NAT GATEWAY FROM MGMT NETWORK

resource "aws_route" "TRF_Nat_Route_MGMT_Net_01" {

    route_table_id = aws_route_table.rt-mgmt-0001.id
    destination_cidr_block = var.destinationdefault
    nat_gateway_id = aws_nat_gateway.nat-gw-0002.id

}

### ASSOCIATE NETWORKS TO ROUTE TABLE

resource "aws_route_table_association" "vpc-corp-0001_association_pub_01" {

    subnet_id      = aws_subnet.pub-net-01.id
    route_table_id = aws_route_table.rt-public-0001.id

}

resource "aws_route_table_association" "vpc-corp-0001_association_pub_02" {

    subnet_id      = aws_subnet.pub-net-02.id
    route_table_id = aws_route_table.rt-public-0001.id

}

resource "aws_route_table_association" "vpc-corp-0001_association_pub_03" {

    subnet_id      = aws_subnet.pub-net-03.id
    route_table_id = aws_route_table.rt-public-0001.id

}

resource "aws_route_table_association" "vpc-corp-0001_association_pub_04" {

    subnet_id      = aws_subnet.pub-net-04.id
    route_table_id = aws_route_table.rt-public-0001.id

}

resource "aws_route_table_association" "vpc-corp-0001_association_priv_01" {

    subnet_id      = aws_subnet.priv-net-01.id
    route_table_id = aws_route_table.rt-private-0001.id

}

resource "aws_route_table_association" "vpc-corp-0001_association_priv_02" {

    subnet_id      = aws_subnet.priv-net-02.id
    route_table_id = aws_route_table.rt-private-0001.id

}

resource "aws_route_table_association" "vpc-corp-0001_association_priv_03" {

    subnet_id      = aws_subnet.priv-net-03.id
    route_table_id = aws_route_table.rt-private-0001.id

}

resource "aws_route_table_association" "vpc-corp-0001_association_priv_04" {

    subnet_id      = aws_subnet.priv-net-04.id
    route_table_id = aws_route_table.rt-private-0001.id

}

resource "aws_route_table_association" "vpc-corp-0001_association_mgmt_01" {

    subnet_id      = aws_subnet.mgmt-net-01.id
    route_table_id = aws_route_table.rt-mgmt-0001.id

}

resource "aws_route_table_association" "vpc-corp-0001_association_mgmt_02" {

    subnet_id      = aws_subnet.mgmt-net-02.id
    route_table_id = aws_route_table.rt-mgmt-0001.id

}

resource "aws_route_table_association" "vpc-corp-0001_association_mgmt_03" {

    subnet_id      = aws_subnet.mgmt-net-03.id
    route_table_id = aws_route_table.rt-mgmt-0001.id

}

resource "aws_route_table_association" "vpc-corp-0001_association_mgmt_04" {

    subnet_id      = aws_subnet.mgmt-net-04.id
    route_table_id = aws_route_table.rt-mgmt-0001.id

}

### CREATE WEBSERVER INSTANCE

resource "aws_instance" "web-0001" {

    ami = "ami-2757f631"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    key_name = "trf-us-east1-0001"
    subnet_id = aws_subnet.pub-net-01.id
    vpc_security_group_ids = [aws_security_group.secgrp-web-0001.id]

    tags = {
        Name        = "web-0001"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

### CREATE GIT INSTANCE

#resource "aws_instance" "gitlab-0001" {
#
#    ami = "ami-01ca03df4a6012157"
#    instance_type = "t3a.xlarge"
#    associate_public_ip_address = false
#    key_name = "trf-us-east1-0001"
#    subnet_id = aws_subnet.mgmt-net-01.id
#    vpc_security_group_ids = [aws_security_group.secgrp-mgmt-0001.id]
#
#    tags = {
#        Name        = "gitlab-0001"
#        origin      = "terraform"
#        team        = "infra"
#        env         = "prod"
#    }
#
#}

#resource "aws_instance" "gitlab-0002" {
#
#    ami = "ami-01ca03df4a6012157"
#    instance_type = "t3a.xlarge"
#    associate_public_ip_address = false
#    key_name = "trf-us-east1-0001"
#    subnet_id = aws_subnet.mgmt-net-03.id
#    vpc_security_group_ids = [aws_security_group.secgrp-mgmt-0001.id]
#
#    tags = {
#        Name        = "gitlab-0002"
#        origin      = "terraform"
#        team        = "infra"
#        env         = "prod"
#    }
#
#}

resource "aws_instance" "aws-fortigate-01" {

    ami = "ami-016ac6c1a802f99a1"
    instance_type = "c5.large"
    associate_public_ip_address = false
    key_name = "fortigate"
    subnet_id = aws_subnet.priv-net-01.id
    vpc_security_group_ids = [aws_security_group.secgrp-fgtwan-0001.id]

    tags = {
        Name        = "aws-fortigate-01"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

### CREATE LOADBALANCE FORTIGATE

resource "aws_lb" "lb-fortigate-0001" {

    name               = "lb-fortigate-0001"
    internal           = false
    load_balancer_type = "network"
    subnets            = [aws_subnet.pub-net-01.id,aws_subnet.pub-net-02.id,aws_subnet.pub-net-03.id,aws_subnet.pub-net-04.id]

    enable_deletion_protection = false

    tags = {
        Name        = "lb-fortigate-0001"
        origin      = "terraform"
        team        = "infra"
        env         = "prod"
    }

}

### CREATING LISTENER

resource "aws_lb_listener" "lb-list-fortigate-0001" {

    load_balancer_arn = aws_lb.lb-fortigate-0001.arn
    port              = "443"
    protocol          = "TCP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.tg-fortigate-0001.arn
    }

}

resource "aws_lb_listener" "lb-list-fortigate-0002" {

    load_balancer_arn = aws_lb.lb-fortigate-0001.arn
    port              = "40443"
    protocol          = "TCP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.tg-fortigate-0002.arn
    }

}

### CREATE TARGET GROUP

resource "aws_lb_target_group" "tg-fortigate-0001" {

    name     = "tg-fortigate-0001"
    port     = 443
    protocol = "TCP"

    health_check {
        protocol = "TCP"
        interval = 10
    }

    vpc_id   = aws_vpc.vpc-corp-0001.id

}

### CREATE TARGET GROUP

resource "aws_lb_target_group" "tg-fortigate-0002" {

    name     = "tg-fortigate-0002"
    port     = 40443
    protocol = "TCP"

    health_check {
        protocol = "TCP"
        interval = 10
    }

    vpc_id   = aws_vpc.vpc-corp-0001.id

}

### ATTACH INSTANCE TO LB TARGET GROUP

resource "aws_lb_target_group_attachment" "lb-tg-attach-0001" {

    target_group_arn = aws_lb_target_group.tg-fortigate-0001.arn
    target_id        = aws_instance.aws-fortigate-01.id
    port             = 443

}

resource "aws_lb_target_group_attachment" "lb-tg-attach-0002" {

    target_group_arn = aws_lb_target_group.tg-fortigate-0002.arn
    target_id        = aws_instance.aws-fortigate-01.id
    port             = 40443

}










### CREATE LOADBALANCE GITLAB

#resource "aws_lb" "lb-gitlab-0001" {
#
#    name               = "lb-gitlab-0001"
#    internal           = false
#    load_balancer_type = "application"
#    security_groups    = [aws_security_group.secgrp-web-0001.id]
#    subnets            = [aws_subnet.pub-net-01.id,aws_subnet.pub-net-02.id,aws_subnet.pub-net-03.id,aws_subnet.pub-net-04.id]
#
#    enable_deletion_protection = false
#
#    access_logs {
#        bucket  = "woclandiner-bucket-0001"
#        prefix  = "lb-gitlab-0001"
#        enabled = true
#    }
#
#    tags = {
#        Name        = "lb-gitlab-0001"
#        origin      = "terraform"
#        team        = "infra"
#        env         = "prod"
#    }
#
#}

### CREATE TARGET GROUP

#resource "aws_lb_target_group" "target-group-gitlab-0001" {
#
#    name     = "target-group-gitlab-0001"
#    port     = 80
#    protocol = "HTTP"
#
#    health_check {
#        matcher  = "200,302"
#        interval = 10
#    }
#
#    vpc_id   = aws_vpc.vpc-corp-0001.id
#
#}

### ATTACH INSTANCE TO LB TARGET GROUP 

#resource "aws_lb_target_group_attachment" "lb-target-group-attach-0001" {
#
#    target_group_arn = aws_lb_target_group.target-group-gitlab-0001.arn
#    target_id        = aws_instance.gitlab-0001.id
#    port             = 80
#
#}

### ATTACH INSTANCE TO LB TARGET GROUP 

#resource "aws_lb_target_group_attachment" "lb-target-group-attach-0002" {
#
#    target_group_arn = aws_lb_target_group.target-group-gitlab-0001.arn
#    target_id        = aws_instance.gitlab-0002.id
#    port             = 80
#
#}

### CREATING LISTENER

#resource "aws_lb_listener" "lb-listener-0001" {
#
#    load_balancer_arn = aws_lb.lb-gitlab-0001.arn
#    port              = "80"
#    protocol          = "HTTP"
#    ssl_policy        = "ELBSecurityPolicy-2016-08"
#    certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
#
#    default_action {
#        type             = "forward"
#        target_group_arn = aws_lb_target_group.target-group-gitlab-0001.arn
#    }
#
#}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock-0001" {

    name="terraform-lock"
    read_capacity=5
    write_capacity=5
    hash_key="LockID"
    attribute{
        name="LockID"
        type="S"
    }

}

#resource "aws_db_subnet_group" "rds-subnet-group-0001" {
#
#    name       = "db-subnet-group-gitlab-0001"
#    subnet_ids = [aws_subnet.priv-net-01.id,aws_subnet.priv-net-02.id,aws_subnet.priv-net-03.id,aws_subnet.priv-net-04.id]
#
#    tags = {
#        Name = "My DB subnet group"
#    }
#
#}


#resource "aws_rds_cluster" "rds-aurora-postgre-gitlab-0001" {
#
#    cluster_identifier        = "rds-aurora-postgre-gitlab-0001"
#    engine                    = "aurora-postgresql"
#    database_name             =  "gitlabhq_production"
#    master_username           = "gitlab"
#    master_password           = "woclandiner"
#    backup_retention_period   = 30
#    preferred_backup_window   = "00:00-03:00"
#    deletion_protection       = false
#    engine_mode               = "serverless"
#    db_subnet_group_name      = aws_db_subnet_group.rds-subnet-group-0001.id
#    vpc_security_group_ids    = [aws_security_group.secgrp-rds-0001.id]
#    final_snapshot_identifier = "snap-rds-postgre-0001"
#
#}

#resource "aws_elasticache_subnet_group" "subnet-group-redis-gitlab-0001" {
#
#    name       = "subnet-group-redis-gitlab-0001"
#    subnet_ids = [aws_subnet.priv-net-01.id,aws_subnet.priv-net-02.id,aws_subnet.priv-net-03.id,aws_subnet.priv-net-04.id]
#
#}

#resource "aws_elasticache_replication_group" "redis-rep-group-0001" {
#
#    automatic_failover_enabled    = true
#    availability_zones            = ["us-east-1a", "us-east-1c"]
#    replication_group_id          = "redis-rg01"
#    replication_group_description = "Replication Group Redis Gitlab"
#    engine                        = "redis"
#    engine_version                = "5.0.6"
#    node_type                     = "cache.t2.small"
#    number_cache_clusters         = 2
#    parameter_group_name          = "default.redis5.0"
#    security_group_ids            = [aws_security_group.secgrp-redis-0001.id]
#    subnet_group_name             = aws_elasticache_subnet_group.subnet-group-redis-gitlab-0001.id
#    port                          = 6379
#
#    lifecycle {
#        ignore_changes = [number_cache_clusters]
#    }
#
#}

#resource "aws_elasticache_cluster" "redis-gitlab-0001" {
#    count = 1
#
#    cluster_id           = "redis-cl01-${count.index}"
#    replication_group_id = "${aws_elasticache_replication_group.redis-rep-group-0001.id}"
#}

