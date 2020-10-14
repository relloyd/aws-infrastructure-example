variable "aws_iam_root_account_id" {
  type        = string
  description = "account id of the root IAM account"
  default     = "446258565969"
}

variable "aws_iam_simple_account_arn" {
  type        = string
  description = "under-privileged account to grant admin role to"
  default     = "arn:aws:iam::446258565969:user/deployer"
}
