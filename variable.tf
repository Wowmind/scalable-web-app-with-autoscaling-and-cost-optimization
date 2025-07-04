variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "instance_type" {
  default = "t3.micro"
}

variable "user" {
  default = "LW4gInVzZXIiIA0K"
}

variable "pass" {
  default = "LW4gIjEyMzQ1NiIgDQo="
}
