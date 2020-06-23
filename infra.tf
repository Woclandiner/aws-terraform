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

resource "aws_security_group_rule" "SSH" {

    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_group_id = aws_security_group.TRF_SG_DB.id
    source_security_group_id = aws_security_group.TRF_SG_WEB.id

}

resource "aws_security_group_rule" "MYSQL" {

    type        = "ingress"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_group_id = aws_security_group.TRF_SG_DB.id
    source_security_group_id = aws_security_group.TRF_SG_WEB.id

}

### CREATE SUBNETS

resource "aws_subnet" "TRF_Ext_Sub" {

    vpc_id                  = aws_vpc.TRF_vpc.id
    cidr_block              = var.externalsubnet
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone1

    tags = {
    Name = "TRF_External_Subnet"
    Origin = "TRF"
    }

}

resource "aws_subnet" "TRF_Int_Sub" {

    vpc_id                  = aws_vpc.TRF_vpc.id
    cidr_block              = var.internalsubnet
    map_public_ip_on_launch = false
    availability_zone       = var.availabilityzone2

    tags = {
    Name = "TRF_External_Subnet"
    Origin = "TRF"
    }

}

### CREATE INTERNET GATEWAY

resource "aws_internet_gateway" "TRF_IGW" {

    vpc_id = aws_vpc.TRF_vpc.id

    tags = {
        Name = "TRF_IGW"
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
