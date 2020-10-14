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

  tags = {
    project = "matchesfashion"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "matchesfashion"
  description = "Security group for use with MatchesFashioin EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    project = "matchesfashion"
  }
}

resource "aws_network_interface" "this" {
  count = 1

  subnet_id = tolist(module.vpc.public_subnets)[count.index]

  tags = {
    project = "matchesfashion"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
  tags = {
    project = "matchesfashion"
  }
}

module "ec2_with_network_interface" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance?ref=4c8ffba6aaa3e4f8ccf53d97b4b0449493af4014"

  instance_count = 1

  name          = "matchesfashion"
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3a.nano"
  key_name      = aws_key_pair.deployer.key_name

  network_interface = [
    {
      device_index          = 0
      network_interface_id  = aws_network_interface.this[0].id
      delete_on_termination = false
    }
  ]

  tags = {
    project = "matchesfashion"
  }
}