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
