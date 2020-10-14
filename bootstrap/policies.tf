// allow_all policy for administrators
resource "aws_iam_policy" "allow_all" {
  name   = "allow_all"
  policy = data.aws_iam_policy_document.allow_all.json
}

data "aws_iam_policy_document" "allow_all" {
  statement {
    effect = "Allow"

    actions = [
      "*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy_attachment" "administrator_access" {
  name = "administrator-access"

  roles = [
    aws_iam_role.administrators.name,
  ]

  policy_arn = aws_iam_policy.allow_all.arn
}
