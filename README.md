## Usage

Creates an IAM policy that allows reading from a AWS S3 bucket.

```hcl
module "s3_iam_policy" {
  source = "dod-iac/s3-iam-policy/aws"

  buckets = var.buckets
  name = format("%s-s3-user-%s", var.application, var.environment)
}
```

Creates an IAM policy that allows reading from an encrypted AWS S3 bucket.

```hcl
module "s3_kms_key" {
  source = "dod-iac/s3-kms-key/aws"

  name = format("alias/app-%s-s3-%s", var.application, var.environment)
  description = format("A KMS key used to encrypt objects at rest in S3 for %s:%s.", var.application, var.environment)
  principals = [var.instance_role_arn]
  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}

module "s3_iam_policy" {
  source = "dod-iac/s3-iam-policy/aws"

  buckets = var.buckets
  keys = [module.s3_kms_key.aws_kms_key_arn]
  name = format("%s-s3-user-%s", var.application, var.environment)
}
```

## Terraform Version

Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.

Terraform 0.11 and 0.12 are not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 2.55.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.55.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) |
| [aws_iam_account_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_account_alias) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_partition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| buckets | The ARNs of the AWS S3 buckets.  Use ["*"] to allow all buckets. | `list(string)` | n/a | yes |
| description | The description of the AWS IAM policy.  Defaults to "The policy for [NAME]." | `string` | `""` | no |
| keys | The ARNs of the AWS KMS keys.  Use ["*"] to allow all keys. | `list(string)` | `[]` | no |
| name | The name of the AWS IAM policy. | `string` | n/a | yes |
| require\_mfa | If true, actions require multi-factor authentication. | `string` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The Amazon Resource Name (ARN) of the AWS IAM policy. |
| id | The id of the AWS IAM policy. |
| name | The name of the AWS IAM policy. |
