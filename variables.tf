variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}
variable "cidr_vpc" {
  type    = string
  default = "10.0.0.0/16"
}
variable "cidr_sub" {
  type    = string
  default = "10.0.1.0/24"
}

variable "instance-type" {
  type    = string
  default = "t2.micro"
}
variable "profile" {
  type    = string
  default = "default"
}

variable "region-master" {
  type    = string
  default = "us-east-2"
}

#How many Jenkins workers to spin up
variable "ami" {
  type    = string
  default = "ami-04bade413263b6269"
}
variable "cred" {
  type    = string
  default = "password"
}
