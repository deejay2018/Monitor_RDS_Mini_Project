resource "aws_iam_user" "prometheus_iam" {
  name = "prometheus_ec2_access"
  path = "/"
  tags = {
    Environment = "Prod"
  }

}

resource "aws_iam_access_key" "prometheus_access_key" {
  user = aws_iam_user.prometheus_iam.name
}

resource "aws_iam_user_policy" "prometheus_role" {
  name = "prometheus_ec2_access_role"
  user = aws_iam_user.prometheus_iam.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:Describe*",
            "Resource": "*"
        }
    ]
}
EOF
}

