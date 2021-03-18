variable "buckets" {
  type        = list(string)
  description = "The ARNs of the AWS S3 buckets.  Use [\"*\"] to allow all buckets."
}

variable "description" {
  type        = string
  description = "The description of the AWS IAM policy.  Defaults to \"The policy for [NAME].\""
  default     = ""
}

variable "keys" {
  type        = list(string)
  description = "The ARNs of the AWS KMS keys.  Use [\"*\"] to allow all keys."
  default     = []
}

variable "name" {
  type        = string
  description = "The name of the AWS IAM policy."
}

variable "require_mfa" {
  type        = string
  description = "If true, actions require multi-factor authentication."
  default     = false
}
