provider "aws" {
  region = "ap-southeast-2"
}

terraform {
  backend "s3" {
    bucket = "badri-terraform-remote-state"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

module "webserver_cluster" {

  source                 = "../../../modules/services/webserver-cluster"
  db_remote_state_bucket = "badri-terraform-remote-state"
  db_remote_state_key    = "stage/data-store/mysql/terraform.tfstate"
  cluster_name           = "staging_web_cluser"

}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name  = "scale_out_during_business_hours"
  min_size               = 2
  max_size               = 5
  desired_capacity       = 2
  recurrence             = "0 9 * * *"
  autoscaling_group_name = module.webserver_cluster.webserver_asg_name
}

resource "aws_autoscaling_schedule" "scale_in_post_business_hours" {
  scheduled_action_name  = "scale_in_post_business_hours"
  min_size               = 2
  max_size               = 5
  desired_capacity       = 2
  recurrence             = "0 17 * * *"
  autoscaling_group_name = module.webserver_cluster.webserver_asg_name
}

output "elb_dns_name" {
  value = module.webserver_cluster.elb_dns_name
}
