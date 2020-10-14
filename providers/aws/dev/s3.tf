resource "aws_s3_bucket" "bucket" {
  bucket = "matchesfashion.halfpipe.sh"
  acl = "private"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = templatefile("${path.module}/s3-bucket-policy.json.tpl", {
    ec2_instance_role = aws_iam_role.ec2_instance_role,
    bucket_arn = aws_s3_bucket.bucket.arn
  })
}