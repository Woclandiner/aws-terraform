
### GET Account ID of AWS ELB Servive Account
data "aws_elb_service_account" "main" {}

### CREATE BUCKET

resource "aws_s3_bucket" "TRF_bucket_0001" {

    bucket = "woclandiner-bucket-0001"
    acl    = "private"

    policy = <<POLICY
{
            "Id": "policy_elb_gitlab_0001",
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
        Name        = "TRF-woclandiner-bucket-0001"
        Environment = "TRF"
    }

}

### CREATE VPC

resource "aws_vpc" "TRF_vpc" {

    cidr_block           = var.CIDR01
    instance_tenancy     = var.instancetenancy
    enable_dns_support   = var.dnssupport
    enable_dns_hostnames = var.dnshostnames

    tags = {

        Name = "TRF_vpc"
        Origin = "TRF"
    }

} # end resource

### ADD SECONDARY CIDR  

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {

    vpc_id     = aws_vpc.TRF_vpc.id
    cidr_block = var.CIDR04

}

### ADD THIRD CIDR  

resource "aws_vpc_ipv4_cidr_block_association" "third_cidr" {

    vpc_id     = aws_vpc.TRF_vpc.id
    cidr_block = var.CIDR05

}

### ADD SECURITY GROUP WEB

resource "aws_security_group" "TRF_SG_WEB" {

    vpc_id      =    aws_vpc.TRF_vpc.id
    name        =    "TRF_SG_WEB"
    description =    "TRF WEB SG"

    tags = {
        Name = "TRF_SG_WEB"
        Origin = "TRF"
    }

}

### CREATING RULES FOR SECURITY GROUP WEB

resource "aws_security_group_rule" "SSH_01" {

    security_group_id = aws_security_group.TRF_SG_WEB.id
    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "HTTP_01" {

    security_group_id = aws_security_group.TRF_SG_WEB.id
    type        = "ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "HTTPS_01" {

    security_group_id = aws_security_group.TRF_SG_WEB.id
    type        = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "ICMP_01" {

    security_group_id = aws_security_group.TRF_SG_WEB.id
    type        = "ingress"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "ALL_01_e" {

    security_group_id = aws_security_group.TRF_SG_WEB.id
    type        = "egress"
    from_port   = -1
    to_port     = -1
    protocol    = "-1"
    cidr_blocks = [var.destinationdefault]

}

### ADD SECURITY GROUP RDS

resource "aws_security_group" "TRF_SG_RDS" {

    vpc_id       = aws_vpc.TRF_vpc.id
    name         = "TRF_SG_RDS"
    description  = "RDS SG"

    tags = {
        Name = "TRF_SG_RDS"
        Origin = "TRF"
    }

}

### CREATING RULE FOR SECURITY GROUP RDS
### IT'S NECESSARY TO USE SOURCE SECURITY GROUP AS SOURCE

resource "aws_security_group_rule" "PostgreSQL_01" {

    type        = "ingress"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_group_id = aws_security_group.TRF_SG_RDS.id
    source_security_group_id = aws_security_group.TRF_SG_DB.id

}

### ADD SECURITY GROUP DB

resource "aws_security_group" "TRF_SG_DB" {

    vpc_id       = aws_vpc.TRF_vpc.id
    name         = "TRF_SG_DB"
    description  = "DB SG"

    tags = {
        Name = "TRF_SG_DB"
        Origin = "TRF"
    }

}

### CREATING RULE FOR SECURITY GROUP DB
### IT'S NECESSARY TO USE SOURCE SECURITY GROUP AS SOURCE

resource "aws_security_group_rule" "SSH_02" {

    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_group_id = aws_security_group.TRF_SG_DB.id
    source_security_group_id = aws_security_group.TRF_SG_WEB.id

}

resource "aws_security_group_rule" "MYSQL_01" {

    type        = "ingress"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_group_id = aws_security_group.TRF_SG_DB.id
    source_security_group_id = aws_security_group.TRF_SG_WEB.id

}

resource "aws_security_group_rule" "HTTP_04" {

    type        = "ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_group_id = aws_security_group.TRF_SG_DB.id
    source_security_group_id = aws_security_group.TRF_SG_WEB.id

}

resource "aws_security_group_rule" "HTTPS_04" {

    type        = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_group_id = aws_security_group.TRF_SG_DB.id
    source_security_group_id = aws_security_group.TRF_SG_WEB.id

}

resource "aws_security_group_rule" "ALL_02_e" {

    security_group_id = aws_security_group.TRF_SG_DB.id
    type        = "egress"
    from_port   = -1
    to_port     = -1
    protocol    = "-1"
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group" "TRF_SG_MGMT" {

    vpc_id       = aws_vpc.TRF_vpc.id
    name         = "TRF_SG_MGMT"
    description  = "MGMT SG"

    tags = {
        Name = "TRF_SG_MGMT"
        Origin = "TRF"
    }

}

### CREATING RULE FOR SECURITY GROUP MGMT

resource "aws_security_group_rule" "SSH_03" {

    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_group_id = aws_security_group.TRF_SG_MGMT.id
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "RDP_01" {

    type        = "ingress"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    security_group_id = aws_security_group.TRF_SG_MGMT.id
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "HTTP_02" {

    type        = "ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_group_id = aws_security_group.TRF_SG_MGMT.id
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "HTTPS_02" {

    type        = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_group_id = aws_security_group.TRF_SG_MGMT.id
    cidr_blocks = [var.destinationdefault]

}

### CREATE SUBNETS

resource "aws_subnet" "TRF_Ext_Sub_01" {

    vpc_id                  = aws_vpc.TRF_vpc.id
    cidr_block              = var.externalsubnet01
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone1

    tags = {
    Name = "TRF_External_Subnet_01"
    Origin = "TRF"
    }

}

resource "aws_subnet" "TRF_Ext_Sub_02" {

    vpc_id                  = aws_vpc.TRF_vpc.id
    cidr_block              = var.externalsubnet02
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone2

    tags = {
    Name = "TRF_External_Subnet_02"
    Origin = "TRF"
    }

}

resource "aws_subnet" "TRF_Int_Sub_01" {

    vpc_id                  = aws_vpc.TRF_vpc.id
    cidr_block              = var.internalsubnet01
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone1

    tags = {
    Name = "TRF_Internal_Subnet_01"
    Origin = "TRF"
    }

}

resource "aws_subnet" "TRF_Int_Sub_02" {

    vpc_id                  = aws_vpc.TRF_vpc.id
    cidr_block              = var.internalsubnet02
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone2

    tags = {
    Name = "TRF_Internal_Subnet_02"
    Origin = "TRF"
    }

}

resource "aws_subnet" "TRF_MGMT_Sub_01" {

    vpc_id                  = aws_vpc.TRF_vpc.id
    cidr_block              = var.mgmtsubnet01
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone1

    tags = {
    Name = "TRF_MGMT_Subnet_01"
    Origin = "TRF"
    }

}

resource "aws_subnet" "TRF_MGMT_Sub_02" {

    vpc_id                  = aws_vpc.TRF_vpc.id
    cidr_block              = var.mgmtsubnet02
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone2

    tags = {
    Name = "TRF_MGMT_Subnet_02"
    Origin = "TRF"
    }

}

### CREATE INTERNET GATEWAY

resource "aws_internet_gateway" "TRF_IGW_01" {

    vpc_id = aws_vpc.TRF_vpc.id

    tags = {
        Name = "TRF_IGW_01"
        Origin = "TRF"
    }

}

### CREATE ROUTE TABLE

resource "aws_route_table" "TRF_RT_PUBLIC" {

    vpc_id = aws_vpc.TRF_vpc.id

    tags = {
        Name = "TRF_RT_PUB"
        Origin = "TRF"
    }

}

resource "aws_route_table" "TRF_RT_INTERNAL_01" {

    vpc_id = aws_vpc.TRF_vpc.id

    tags = {
        Name = "TRF_RT_INT"
        Origin = "TRF"
    }
}

resource "aws_route_table" "TRF_RT_INTERNAL_02" {

    vpc_id = aws_vpc.TRF_vpc.id

    tags = {
        Name = "TRF_RT_INT"
        Origin = "TRF"
    }
}

resource "aws_route_table" "TRF_RT_MGMT_01" {

    vpc_id = aws_vpc.TRF_vpc.id

    tags = {
        Name = "TRF_RT_MGMT"
        Origin = "TRF"
    }
}

resource "aws_route_table" "TRF_RT_MGMT_02" {

    vpc_id = aws_vpc.TRF_vpc.id

    tags = {
        Name = "TRF_RT_MGMT"
        Origin = "TRF"
    }
}

### CREATE ROUTE TO INTERNET

resource "aws_route" "TRF_Internet_Route" {

    route_table_id = aws_route_table.TRF_RT_PUBLIC.id
    destination_cidr_block = var.destinationdefault
    gateway_id = aws_internet_gateway.TRF_IGW_01.id

}

### CREATE ELASTIC IP

resource "aws_eip" "TRF_EIP_01"{

    tags = {
        Name = "TRF_EIP_01"
        Origin = "TRF"
    }

}

resource "aws_eip" "TRF_EIP_02"{

    tags = {
        Name = "TRF_EIP_02"
        Origin = "TRF"
    }

}

resource "aws_eip" "TRF_EIP_03"{

    tags = {
        Name = "TRF_EIP_03"
        Origin = "TRF"
    }

}

resource "aws_eip" "TRF_EIP_04"{

    tags = {
        Name = "TRF_EIP_04"
        Origin = "TRF"
    }

}

### CREATE NAT GATEWAY

resource "aws_nat_gateway" "TRF_NAT_GW_01" {
    subnet_id = aws_subnet.TRF_Ext_Sub_01.id
    allocation_id = aws_eip.TRF_EIP_01.id

    tags = {
        Name = "TRF_NAT_GW_01"
        Origin = "TRF"
    }

}

### CREATE NAT GATEWAY

resource "aws_nat_gateway" "TRF_NAT_GW_02" {
    subnet_id = aws_subnet.TRF_Ext_Sub_02.id
    allocation_id = aws_eip.TRF_EIP_02.id

    tags = {
        Name = "TRF_NAT_GW_02"
        Origin = "TRF"
    }

}

### CREATE NAT GATEWAY

resource "aws_nat_gateway" "TRF_NAT_GW_03" {
    subnet_id = aws_subnet.TRF_Ext_Sub_01.id
    allocation_id = aws_eip.TRF_EIP_03.id

    tags = {
        Name = "TRF_NAT_GW_03"
        Origin = "TRF"
    }

}

### CREATE NAT GATEWAY

resource "aws_nat_gateway" "TRF_NAT_GW_04" {
    subnet_id = aws_subnet.TRF_Ext_Sub_02.id
    allocation_id = aws_eip.TRF_EIP_04.id

    tags = {
        Name = "TRF_NAT_GW_04"
        Origin = "TRF"
    }

}

### CREATE ROUTE TO NAT GATEWAY FROM INTERNAL NETWORK

resource "aws_route" "TRF_Nat_Route_Int_Net_01" {

    route_table_id = aws_route_table.TRF_RT_INTERNAL_01.id
    destination_cidr_block = var.destinationdefault
    nat_gateway_id = aws_nat_gateway.TRF_NAT_GW_01.id

}

resource "aws_route" "TRF_Nat_Route_Int_Net_02" {

    route_table_id = aws_route_table.TRF_RT_INTERNAL_02.id
    destination_cidr_block = var.destinationdefault
    nat_gateway_id = aws_nat_gateway.TRF_NAT_GW_02.id

}

### CREATE ROUTE TO NAT GATEWAY FROM MGMT NETWORK

resource "aws_route" "TRF_Nat_Route_MGMT_Net_01" {

    route_table_id = aws_route_table.TRF_RT_MGMT_01.id
    destination_cidr_block = var.destinationdefault
    nat_gateway_id = aws_nat_gateway.TRF_NAT_GW_03.id

}

resource "aws_route" "TRF_Nat_Route_MGMT_Net_02" {

    route_table_id = aws_route_table.TRF_RT_MGMT_02.id
    destination_cidr_block = var.destinationdefault
    nat_gateway_id = aws_nat_gateway.TRF_NAT_GW_04.id

}

### ASSOCIATE NETWORKS TO ROUTE TABLE

resource "aws_route_table_association" "TRF_vpc_association_pub_01" {

    subnet_id      = aws_subnet.TRF_Ext_Sub_01.id
    route_table_id = aws_route_table.TRF_RT_PUBLIC.id

}

resource "aws_route_table_association" "TRF_vpc_association_pub_02" {

    subnet_id      = aws_subnet.TRF_Ext_Sub_02.id
    route_table_id = aws_route_table.TRF_RT_PUBLIC.id

}

resource "aws_route_table_association" "TRF_vpc_association_int_01" {

    subnet_id      = aws_subnet.TRF_Int_Sub_01.id
    route_table_id = aws_route_table.TRF_RT_INTERNAL_01.id

}

resource "aws_route_table_association" "TRF_vpc_association_int_02" {

    subnet_id      = aws_subnet.TRF_Int_Sub_02.id
    route_table_id = aws_route_table.TRF_RT_INTERNAL_02.id

}

resource "aws_route_table_association" "TRF_vpc_association_mgmt_01" {

    subnet_id      = aws_subnet.TRF_MGMT_Sub_01.id
    route_table_id = aws_route_table.TRF_RT_MGMT_01.id

}

resource "aws_route_table_association" "TRF_vpc_association_mgmt_02" {

    subnet_id      = aws_subnet.TRF_MGMT_Sub_02.id
    route_table_id = aws_route_table.TRF_RT_MGMT_02.id

}

### CREATE WEBSERVER INSTANCE

resource "aws_instance" "WebServer_TRF" {

    ami = "ami-2757f631"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    key_name = "trf-us-east1-0001"
    subnet_id = aws_subnet.TRF_Ext_Sub_01.id
    vpc_security_group_ids = [aws_security_group.TRF_SG_WEB.id]

    tags = {
        Name = "WebServer"
        Origin = "TRF"
    }

}

### CREATE DATABASE INSTANCE

resource "aws_instance" "Database_TRF" {

    ami = "ami-2757f631"
    instance_type = "t2.micro"
    associate_public_ip_address = false
    key_name = "trf-us-east1-0001"
    subnet_id = aws_subnet.TRF_Int_Sub_01.id
    vpc_security_group_ids = [aws_security_group.TRF_SG_DB.id]

    tags = {
        Name = "Database"
        Origin = "TRF"
    }

}

### CREATE GIT INSTANCE

resource "aws_instance" "GITLAB_TRF" {

    ami = "ami-01ca03df4a6012157"
    instance_type = "t3a.xlarge"
    associate_public_ip_address = false
    key_name = "trf-us-east1-0001"
    subnet_id = aws_subnet.TRF_Int_Sub_01.id
    vpc_security_group_ids = [aws_security_group.TRF_SG_DB.id]

    tags = {
        Name = "GITLAB"
        Origin = "TRF"
    }

    # Copy in the bash script we want to execute.

    provisioner "file" {
        source      = "./install-gitlab"
        destination = "/tmp/install-gitlab"
    }

    # Change permissions on bash script and execute from ec2-user.

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/install-gitlab",
            "sudo /tmp/install-gitlab",
        ]
    }

    # Login to the ec2-user with the aws key.
    connection {
        type        = "ssh"
        user        = "centos"
        password    = ""
        private_key = file("~/trf-us-east1-0001.pem")
        host        = self.public_ip
    }

}

### CREATE LOADBALANCE

resource "aws_lb" "TRF-lb-gitlab-001" {

    name               = "TRF-lb-gitlab-001"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.TRF_SG_WEB.id]
    subnets            = [aws_subnet.TRF_Ext_Sub_01.id,aws_subnet.TRF_Ext_Sub_02.id]

    enable_deletion_protection = false

    access_logs {
        bucket  = "woclandiner-bucket-0001"
        prefix  = "TRF-lb-gitlab-001"
        enabled = true
    }

    tags = {
        Environment = "prod"
        Name = "GITLAB_LB"
        Origin = "TRF"
    }

}

### CREATE TARGET GROUP

resource "aws_lb_target_group" "TRF-target-group-gitlab-0001" {

    name     = "target-group-gitlab-0001"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.TRF_vpc.id

}

### ATTACH INSTANCE TO LB TARGET GROUP 

resource "aws_lb_target_group_attachment" "TRF_lb_target_group_attach_0001" {

    target_group_arn = aws_lb_target_group.TRF-target-group-gitlab-0001.arn
    target_id        = aws_instance.GITLAB_TRF.id
    port             = 80

}

### CREATING LISTENER

resource "aws_lb_listener" "TRF_lb_listener_0001" {

    load_balancer_arn = aws_lb.TRF-lb-gitlab-001.arn
    port              = "80"
    protocol          = "HTTP"
#    ssl_policy        = "ELBSecurityPolicy-2016-08"
#    certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TRF-target-group-gitlab-0001.arn
    }

}
