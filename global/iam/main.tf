provider "aws" {
  region = "ap-southeast-1"
}

variable "user_names" {
  type    = list(string)
  default = ["pappu", "neya", "poppy"]

}

resource "aws_iam_user" "iam_user" {
  count = length(var.user_names)
  name  = element(var.user_names, count.index)
}

resource "aws_iam_user_policy_attachment" "iam_user_ec2_readonly" {
  count      = length(var.user_names)
  user       = element(var.user_names, count.index)
  policy_arn = aws_iam_policy.ec2_readonly.arn
}


data "aws_iam_policy_document" "ec2_readonly" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
    sid       = "ec2_read_only"
  }
}

resource "aws_iam_policy" "ec2_readonly" {
  name   = "ec2-read-only"
  policy = data.aws_iam_policy_document.ec2_readonly.json
}

output "iam_list_users_arn" {
  value = [aws_iam_user.iam_user.*.arn]
}
