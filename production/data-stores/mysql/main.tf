provider "aws" {

  region = "ap-southeast-2"
}

terraform {
  backend "s3" {
    bucket = "badri-terraform-remote-state"
    key    = "production/data-store/mysql/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

module "aws_db_instance" {
  source          = "../../../modules/data-stores/mysql"
  db_cluster_name = "MySQLProdDB"
  db_password     = "MySQLProdDBPassword"
  db_username     = "MySQLprodDBUsername"
}
