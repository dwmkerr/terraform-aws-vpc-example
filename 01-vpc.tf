//  Define the VPC.
resource "aws_vpc" "cluster" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
}

//  Create an Internet Gateway for the VPC.
resource "aws_internet_gateway" "cluster_gateway" {
  vpc_id = "${aws_vpc.cluster.id}"
}

//  Create each of the subnets.
resource "aws_subnet" "public-subnet" {
  count                   = "${length(var.subnets)}"
  vpc_id                  = "${aws_vpc.cluster.id}"
  availability_zone       = "${element(keys(var.subnets), count.index)}"
  cidr_block              = "${element(values(var.subnets), count.index)}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.cluster_gateway"]
}

//  Create a route table allowing all addresses access to the IGW.
resource "aws_route_table" "public" {
  vpc_id       = "${aws_vpc.cluster.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.cluster_gateway.id}"
  }
}

//  Now associate the route table with the public subnet - giving
//  all public subnet instances access to the internet.
resource "aws_route_table_association" "public-subnet" {
  count          = "${length(var.subnets)}"
  subnet_id      = "${element(aws_subnet.public-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
