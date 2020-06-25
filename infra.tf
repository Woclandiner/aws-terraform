### DEFINING PROVIDER
##


provider "aws" {
    profile = "default"
    region = "us-east-1"
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

### ADD SECURITY GROUPS

resource "aws_security_group" "TRF_SG_WEB" {

    vpc_id      =    aws_vpc.TRF_vpc.id
    name        =    "TRF_SG_WEB"
    description =    "TRF WEB SG"

    ingress {
        cidr_blocks = [var.destinationdefault]
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        description = "HTTP"
    }

        ingress {
        cidr_blocks = [var.destinationdefault]
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        description = "HTTPS"
    }

        tags = {
            Name = "TRF_SG_WEB"
            Origin = "TRF"
        }

}

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

resource "aws_security_group_rule" "SSH_01" {

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
### IT'S NECESSARY TO USE SOURCE SECURITY GROUP AS SOURCE

resource "aws_security_group_rule" "SSH_02" {

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

resource "aws_security_group_rule" "HTTP_01" {

    type        = "ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_group_id = aws_security_group.TRF_SG_MGMT.id
    cidr_blocks = [var.destinationdefault]

}

resource "aws_security_group_rule" "HTTPS_01" {

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

resource "aws_route_table" "TRF_RT_INTERNAL" {

    vpc_id = aws_vpc.TRF_vpc.id

    tags = {
        Name = "TRF_RT_INT"
        Origin = "TRF"
    }
}

resource "aws_route_table" "TRF_RT_MGMT" {

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

### CREATE ROUTE TO NAT GATEWAY FROM INTERNAL NETWORK

resource "aws_route" "TRF_Nat_Route_Int_Net" {

    route_table_id = aws_route_table.TRF_RT_INTERNAL.id
    destination_cidr_block = var.destinationdefault
    nat_gateway_id = aws_nat_gateway.TRF_NAT_GW_01.id

}

### CREATE ROUTE TO NAT GATEWAY FROM MGMT NETWORK

resource "aws_route" "TRF_Nat_Route_MGMT_Net" {

    route_table_id = aws_route_table.TRF_RT_MGMT.id
    destination_cidr_block = var.destinationdefault
    nat_gateway_id = aws_nat_gateway.TRF_NAT_GW_02.id

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
    route_table_id = aws_route_table.TRF_RT_INTERNAL.id

}

resource "aws_route_table_association" "TRF_vpc_association_int_02" {

    subnet_id      = aws_subnet.TRF_Int_Sub_02.id
    route_table_id = aws_route_table.TRF_RT_INTERNAL.id

}

resource "aws_route_table_association" "TRF_vpc_association_mgmt_01" {

    subnet_id      = aws_subnet.TRF_MGMT_Sub_01.id
    route_table_id = aws_route_table.TRF_RT_MGMT.id

}

resource "aws_route_table_association" "TRF_vpc_association_mgmt_02" {

    subnet_id      = aws_subnet.TRF_MGMT_Sub_02.id
    route_table_id = aws_route_table.TRF_RT_MGMT.id

}

### CREATE WEBSERVER INSTANCE

resource "aws_instance" "WebServer_TRF" {

    ami = "ami-2757f631"
    instance_type = "t2.micro"
    associate_public_ip_address = true
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
    subnet_id = aws_subnet.TRF_Int_Sub_01.id
    vpc_security_group_ids = [aws_security_group.TRF_SG_DB.id]

    tags = {
        Name = "Database"
        Origin = "TRF"
    }

}
