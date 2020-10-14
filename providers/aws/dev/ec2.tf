resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2_instance_role_matchesfashion"

  assume_role_policy = templatefile("${path.module}/ec2-policy.json.tpl", {
    bucket_arn = aws_s3_bucket.bucket.arn
  })

  tags = {
    project = "matchesfashion"
  }
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_instance_role.name
}

