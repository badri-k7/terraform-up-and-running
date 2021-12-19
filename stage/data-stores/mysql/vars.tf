variable "stage_random1" {
  description = "The password for MySQL database"
  default     = "Thisisdbpassword"
}

variable "stage_random2" {
  description = "This is a DB cluster name"
  default     = "MySQLStagingDB"
}

variable "stage_random3" {
  description = "This is a DB user name"
  default     = "admin"
}
