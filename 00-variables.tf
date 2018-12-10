variable "region" {
  description = "The region to deploy the VPC in, e.g: us-east-1."
  type = "string"
}

variable "instance_size" {
  description = "The size of the cluster nodes, e.g: t2.medium."
  type = "string"
  default = "t2.micro"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC, e.g: 10.0.0.0/16"
  type = "string"
}

variable "subnets" {
  description = "The subnets which is a map of availability zones to CIDR blocks, which subnet nodes will be deployed in."
  type = "map"
}

variable "web_server_count" {
  description = "The number of web servers to run"
  type = "string"
  default = "0"
}

variable "public_key_path" {
  description = "The local public key path, e.g. ~/.ssh/id_rsa.pub"
  type = "string"
  default = ""
}
