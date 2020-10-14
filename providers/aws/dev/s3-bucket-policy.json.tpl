{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BucketAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${ec2_instance_role}"
        ]
      },
      "Resource": "*",
      "Action": [
        "s3:*"
      ]
    },
  ]
}