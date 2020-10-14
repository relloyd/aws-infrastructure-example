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

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "matchesfashion"
  description = "Security group for use with MatchesFashioin EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

resource "aws_network_interface" "this" {
  count = 1

  subnet_id = tolist(module.vpc.public_subnets)[count.index]
}

module "ec2_with_network_interface" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance?ref=4c8ffba6aaa3e4f8ccf53d97b4b0449493af4014"

  instance_count = 1

  name            = "matchesfashion"
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t3a.nano"

  network_interface = [
    {
      device_index          = 0
      network_interface_id  = aws_network_interface.this[0].id
      delete_on_termination = false
    }
  ]
}