variable "cluster_name" {
  description = "The name to use for all cluster resources"
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database remote state"
}

variable "db_remote_state_key" {
  description = "The path for database remote state file"
}

variable "cluster_port_numbers" {
  type        = map(any)
  description = "Server Ingress Port"
  default = {
    port80    = "80"
    port22    = "22"
    port0     = "0"
    port65535 = "65535"
  }
}

variable "ami_id" {
  description = "AMI ID for the webserver cluster"
  default     = "ami-0bd2230cfb28832f7"
}

variable "server_text" {
  description = "The text the webserver should return"
  default     = "Hello world from module variable"
}

variable "instance_type" {
  description = "EC2 instance family type"
  default     = "t2.micro"
}

variable "min_size" {
  type        = number
  description = "Indicate the minimum EC2 instance needed for Autoscaling group"
  default     = 2
}

variable "max_size" {
  type        = number
  description = "Indicate the maximum EC2 instance needed for Autoscaling group"
  default     = 2
}
