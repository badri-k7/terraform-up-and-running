provider "aws" {
  region = "ap-southeast-1"
}

variable "user_names" {
  type    = list(string)
  default = ["pappu", "poppy"]

}

resource "aws_iam_user" "iam_user" {
  for_each=toset(var.user_names)
  name  = each.value
}

resource "aws_iam_user_policy_attachment" "iam_user_ec2_readonly" {
  count      = length(var.user_names)
  user       = var.user_names[count.index]
  policy_arn = aws_iam_policy.ec2_readonly.arn
}


data "aws_iam_policy_document" "ec2_readonly" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
    sid       = "Ec2ReadOnly"
  }
}

resource "aws_iam_policy" "ec2_readonly" {
  name   = "ec2-read-only"
  policy = data.aws_iam_policy_document.ec2_readonly.json
}

output "all_iam_users" {
  value = values(aws_iam_user.iam_user)[*].arn
}
