provider "aws" {
  region = "us-west-1"
}


/* terraform {
  backend "s3" {
    bucket         = "tfsate-remote-backend"
    key            = "jupiter/statefile"
    dynamodb_table = "jupiter-state-locking"
    encrypt        = true
    region         = "us-west-1"
  }
}
 */

module "vpc" {
  source                    = "./vpc"
  tags                      = local.project_tags
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block
  db_subnet_cidr_block      = var.db_subnet_cidr_block
  availability_zone         = var.availability_zone
}

module "alb" {
  source              = "./alb"
  vpc_id              = module.vpc.vpc_id
  public_subnet_az_1a = module.vpc.public_subnet_az_1a
  public_subnet_az_1c = module.vpc.public_subnet_az_1c
  tags                = local.project_tags
  ssl_policy          = var.ssl_policy
  certificate_arn     = var.certificate_arn
}

module "auto-scaling" {
  source              = "./auto-scaling"
  vpc_id              = module.vpc.vpc_id
  apci_jupiter_alb_sg = module.alb.apci_jupiter_alb_sg
  image_id            = var.image_id
  instance_type       = var.instance_type
  key_name            = var.key_name
  public_subnet_az_1a = module.vpc.public_subnet_az_1a
  public_subnet_az_1c = module.vpc.public_subnet_az_1c
  apci_jupiter_tg     = module.alb.apci_jupiter_tg
}

module "compute" {
  source               = "./compute"
  tags                 = local.project_tags
  key_name             = var.key_name
  image_id             = var.image_id
  instance_type        = var.instance_type
  public_subnet_az_1a  = module.vpc.public_subnet_az_1a
  private_subnet_az_1a = module.vpc.private_subnet_az_1a
  private_subnet_az_1c = module.vpc.private_subnet_az_1c
  vpc_id               = module.vpc.vpc_id
}

module "rds" {
  source                  = "./rds"
  db_username             = var.db_username
  db_parameter_group_name = var.db_parameter_group_name
  vpc_id                  = module.vpc.vpc_id
  tags                    = local.project_tags
  db_engine_version       = var.db_engine_version
  db_allocated_storage    = var.db_allocated_storage
  db_instance_class       = var.db_instance_class
  db_subnet_az_1a         = module.vpc.db_subnet_az_1a
  db_subnet_az_1c         = module.vpc.db_subnet_az_1c
  apci_jupiter_bastion_sg = module.compute.apci_jupiter_bastion_sg
}


module "route53" {
  source                    = "./route53"
  apci_jupiter_alb_dns_name = module.alb.apci_jupiter_alb_dns_name
  apci_jupiter_alb_zone_id  = module.alb.apci_jupiter_alb_zone_id
  dns_name                  = var.dns_name
  dns_zone_id               = var.dns_zone_id




}