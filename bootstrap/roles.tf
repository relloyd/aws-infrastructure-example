resource "aws_iam_role" "administrators" {
  name = "administrators"

  assume_role_policy = data.aws_iam_policy_document.administrators_assume_role_policy.json
}

data "aws_iam_policy_document" "administrators_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_iam_root_account_id}:root", var.aws_iam_simple_account_arn]
    }
  }
}
