# variables.tf

variable "region" {
 default = "us-east-1"
}

variable "availabilityzone1" {
 default = "us-east-1a"
}

variable "availabilityzone2" {
 default = "us-east-1b"
}

variable "instancetenancy" {
 default = "default"
}

variable "dnssupport" {
 default = true
}

variable "dnshostnames" {
 default = true
}

variable "CIDR01" {
 default = "10.0.0.0/16"
}

variable "CIDR02" {
 default = "172.16.0.0/16"
}

variable "CIDR03" {
 default = "192.168.0.0/16"
}

variable "CIDR04" {
 default = "10.1.0.0/16"
}

variable "external_subnet" {
 default = "10.0.1.0/24"
}

variable "internal_subnet" {
 default = "10.1.1.0/24"
}

variable "destination_default" {
 default = "0.0.0.0/0"
}

variable "ingresscidrblock" {
 type = list
 default = [ "0.0.0.0/0" ]
}
variable "mappublicip" {
 default = true
}

# end of variables.tf
