terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "app-tf-bucket"
    key = "app/terraform.state"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  #version = "value" if needed

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.avail_zone]
  public_subnets  = [var.subnet_cidr_block]

  public_subnet_tags = {
    Name = "${var.env_prefix}-subnet-1"
  }

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

## Create EC2 with SSH key pair; define SG
module "app-server" {
  instance_type = var.instance_type
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = module.vpc.vpc_id
  image_name = var.image_name
  subnet_id = module.vpc.public_subnets[0]
  allowed_ip = var.allowed_ip
  public_key = var.public_key
  source = "./modules/webserver"
}