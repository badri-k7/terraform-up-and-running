data "aws_availability_zones" "all" {
  all_availability_zones = true
  state                  = "available"
}

data "terraform_remote_state" "db" {

  backend = "s3"

  #config = {
  #  bucket = "badri-terraform-remote-state"
  #  key    = "stage/data-store/mysql/terraform.tfstate"
  #  region = "ap-southeast-1"
  #}
  config = {
    bucket = "${var.db_remote_state_bucket}"
    key    = "${var.db_remote_state_key}"
    region = "ap-southeast-1"
  }
}

data "template_file" "user_data" {

  template = file("user-data.sh")

  vars = {
    db_address = data.terraform_remote_state.db.outputs.address
    db_port    = data.terraform_remote_state.db.outputs.port
  }
}

resource "aws_launch_configuration" "webServerLaunchConfig" {
  image_id        = "ami-0bd2230cfb28832f7"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]
  key_name        = aws_key_pair.badris-mbp.key_name
  user_data       = data.template_file.user_data.rendered
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "webServerAsg" {
  launch_configuration = aws_launch_configuration.webServerLaunchConfig.id
  availability_zones   = data.aws_availability_zones.all.names

  load_balancers    = ["${aws_elb.webServerElb.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 5
  tag {
    key                 = "name"
    value               = "webServerAsg"
    propagate_at_launch = true
  }

}

resource "aws_elb" "webServerElb" {
  name               = "webserver-asg-elb"
  availability_zones = data.aws_availability_zones.all.names
  security_groups    = ["${aws_security_group.webServerElb.id}"]

  listener {
    lb_port           = var.cluster_port_numbers.port80
    lb_protocol       = "http"
    instance_port     = var.cluster_port_numbers.port80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 3
    interval            = 5
    target              = "HTTP:${var.cluster_port_numbers.port80}/"

  }

}

resource "aws_security_group" "webServerElb" {

  name = "sg_${var.cluster_name}-elb"

  ingress {
    from_port   = var.cluster_port_numbers.port80
    to_port     = var.cluster_port_numbers.port80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = var.cluster_port_numbers.port0
    to_port     = var.cluster_port_numbers.port65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance" {

  name = "sg_${var.cluster_name}-instance"
  ingress {
    from_port   = var.cluster_port_numbers.port80
    to_port     = var.cluster_port_numbers.port80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.cluster_port_numbers.port22
    to_port     = var.cluster_port_numbers.port22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = var.cluster_port_numbers.port0
    to_port     = var.cluster_port_numbers.port65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "badris-mbp" {
  key_name   = "badri-macbook-pro"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCSV3A8B/fh19rwJDgIkcsjXUNB565fYuKs1cLkuZTV86rKn5WQrw7nKzQh7HWJMsi8Qpt65KHNIEuKnk9HKyoanO9c1I/5Kkhhmw+nuBau4CoxoXulbCobhCdeBTz2eLs/la1CaODtodN5fVuW9QOwvOTxalqGC1ucdeI8xSVvfL9Z3uGdBcMt3EZe3HzijreCdcdCkzxA2gYuUr7mjIhCopueUNyWxRx9FbHpw3J+cdJYRgG+KLaWQ3NEt9R1ggNbnwkzkTuCEdELC7yQ/Cp0fgULaL0yVu0xli7wS8/W7deFwCc6pp0yGuu+CTNY4nN5l585uDm+bLj5CXfLjj8/gmttwKIqyatHvqolB0WH9y6TQymfq88URBt+N7XskAD09MieTDa/K7E3vPWyLE5eiI6BJQrd0t/ZYKUw9Fsm4c8zQCJ+lHSOk80vdsziJKLtWNsVNyyXV6NVmMDIkJZwk40Jxl7TIUzz/LXN/GBosVLAjhmigheqJqPBgwv5c8= badri@Badris-MBP"
  lifecycle {
    create_before_destroy = true
  }
}

output "elb_dns_name" {
  value = aws_elb.webServerElb.dns_name
}

output "webserver_asg_name" {
  value = aws_autoscaling_group.webServerAsg.name
}
