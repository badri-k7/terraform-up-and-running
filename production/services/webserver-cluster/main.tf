provider "aws" {
  region = "ap-southeast-2"
}

module "webserver_cluster" {

  source = "../../../modules/services/webserver-cluster"
}
