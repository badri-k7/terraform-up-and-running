provider "aws" {

  region = "ap-southeast-2"
}

#terraform {
#  backend "s3" {
#    bucket = "badri-terraform-remote-state"
#    key    = "modules/data-store/mysql/terraform.tfstate"
#    region = "ap-southeast-1"
#  }
#}

resource "aws_db_instance" "mysql" {

  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  name                = var.db_cluster_name
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true

}
