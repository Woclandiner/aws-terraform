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

variable "availabilityzone3" {
 default = "us-east-1c"
}

variable "availabilityzone4" {
 default = "us-east-1d"
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
 default = "10.1.0.0/16"
}

variable "externalsubnet01" {
 default = "10.0.1.0/24"
}

variable "externalsubnet02" {
 default = "10.0.2.0/24"
}

variable "externalsubnet03" {
 default = "10.0.3.0/24"
}

variable "externalsubnet04" {
 default = "10.0.4.0/24"
}

variable "internalsubnet01" {
 default = "10.0.21.0/24"
}

variable "internalsubnet02" {
 default = "10.0.22.0/24"
}

variable "internalsubnet03" {
 default = "10.0.23.0/24"
}

variable "internalsubnet04" {
 default = "10.0.24.0/24"
}

variable "mgmtsubnet01" {
 default = "10.0.251.0/24"
}

variable "mgmtsubnet02" {
 default = "10.0.252.0/24"
}

variable "mgmtsubnet03" {
 default = "10.0.253.0/24"
}

variable "mgmtsubnet04" {
 default = "10.0.254.0/24"
}

variable "destinationdefault" {
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
