terraform {
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "1.0.0"
    }
  }
}

// instantiate AWS provider with a region
provider "aws" {
  region = "ap-south-1"
}

// create 100 users
module "users" {
  source = "./modules/cloudesk-user/"
  for_each = toset([
    for i in range(100) : format("user-%02d", i)
  ])
  name = each.key
}
