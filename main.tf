/**
 * ## Usage
 *
 * Creates an IAM policy that allows reading from a AWS S3 bucket.
 *
 * ```hcl
 * module "s3_iam_policy" {
 *   source = "dod-iac/s3-iam-policy/aws"
 *
 *   buckets = var.buckets
 *   name = format("%s-s3-user-%s", var.application, var.environment)
 * }
 * ```
 *
 * Creates an IAM policy that allows reading from an encrypted AWS S3 bucket.
 *
 * ```hcl
 * module "s3_kms_key" {
 *   source = "dod-iac/s3-kms-key/aws"
 *
 *   name = format("alias/app-%s-s3-%s", var.application, var.environment)
 *   description = format("A KMS key used to encrypt objects at rest in S3 for %s:%s.", var.application, var.environment)
 *   principals = [var.instance_role_arn]
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 *
 * module "s3_iam_policy" {
 *   source = "dod-iac/s3-iam-policy/aws"
 *
 *   buckets = var.buckets
 *   keys = [module.s3_kms_key.aws_kms_key_arn]
 *   name = format("%s-s3-user-%s", var.application, var.environment)
 * }
 * ```
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_caller_identity" "current" {}

data "aws_iam_account_alias" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "main" {

  #
  # DecryptObjects
  #

  dynamic "statement" {
    for_each = length(var.keys) > 0 ? [true] : []
    content {
      sid = "DecryptObjects"
      actions = [
        "kms:ListAliases",
        "kms:Decrypt",
      ]
      effect    = "Allow"
      resources = var.keys
      dynamic "condition" {
        for_each = var.require_mfa ? [true] : []
        content {
          test     = "Bool"
          variable = "aws:MultiFactorAuthPresent"
          values   = ["true"]
        }
      }
    }
  }

  #
  # ListBucket
  #

  statement {
    sid = "ListBucket"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetBucketRequestPayment",
      "s3:GetEncryptionConfiguration",
      "s3:ListBucket",
    ]
    effect    = "Allow"
    resources = var.buckets
    dynamic "condition" {
      for_each = var.require_mfa ? [var.require_mfa] : []
      content {
        test     = "Bool"
        variable = "aws:MultiFactorAuthPresent"
        values   = ["true"]
      }
    }
  }

  #
  # GetObject
  #

  statement {
    sid = "GetObject"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
    ]
    effect    = "Allow"
    resources = formatlist("%s/*", var.buckets)
    dynamic "condition" {
      for_each = var.require_mfa ? [var.require_mfa] : []
      content {
        test     = "Bool"
        variable = "aws:MultiFactorAuthPresent"
        values   = ["true"]
      }
    }
  }

}

resource "aws_iam_policy" "main" {
  name        = var.name
  description = length(var.description) > 0 ? var.description : format("The policy for %s.", var.name)
  policy      = data.aws_iam_policy_document.main.json
}
