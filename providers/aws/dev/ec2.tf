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

module "security_group" {
  source  = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group?ref=b6362f88d065457a6f224e99ceec5f58bce6754b"

  name        = "matchesfashion"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

resource "aws_network_interface" "this" {
  count = 1

  subnet_id = tolist(data.aws_subnet_ids.all.ids)[count.index]
}

module "ec2_with_network_interface" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance?ref=4c8ffba6aaa3e4f8ccf53d97b4b0449493af4014"

  instance_count = 1

  name            = "example-network"
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "c5.large"
  placement_group = aws_placement_group.web.id

  network_interface = [
    {
      device_index          = 0
      network_interface_id  = aws_network_interface.this[0].id
      delete_on_termination = false
    }
  ]
}