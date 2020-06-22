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
