# terraform-aws-vpc-example

[![CircleCI](https://circleci.com/gh/dwmkerr/terraform-aws-vpc-example.svg?style=shield)](https://circleci.com/gh/dwmkerr/terraform-aws-vpc-example)

Small and simple Terraform module to create a VPC which contains a cluster of web servers.

This is the companion to my article:

[Dynamic and Configurable Availability Zones in Terraform](https://www.dwmkerr.com/dynamic-and-configurable-availability-zones-in-terraform/)

This module demonstrates techniques for working with a dynamic set of availability zones.

Terraform 0.11 onwards is required.

## Developer Guide

The following commands may be useful:

| Command         | Usage                                  |
|-----------------|----------------------------------------|
| `make lint`     | Lint the Terraform code with `tflint`. |
| `make circleci` | Run the CircleCI build locally.        |
