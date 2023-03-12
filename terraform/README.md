# DR for CloudHSM

![Test](https://img.shields.io/github/workflow/status/skildops/aws-cloudhsm-dr/test/main?label=Test&style=for-the-badge) ![Checkov](https://img.shields.io/github/workflow/status/skildops/aws-cloudhsm-dr/checkov/main?label=Checkov&style=for-the-badge)

This terraform module will deploy the following services that will periodically copy CloudHSM backups to the DR regions provided by you:
- IAM Role
- IAM Role Policy
- CloudWatch Event
- Lambda Function

**Note:** You need to implement [remote backend](https://www.terraform.io/docs/language/settings/backends/index.html) by yourself and is recommended for state management.

## Requirements

| Name | Version |
|------|---------|
| aws | >= 4.57.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | AWS region in which you want to create resources | `string` | `"us-east-1"` | no |
| profile | AWS CLI profile to use as authentication method | `string` | `null` | no |
| access_key | AWS access key to use as authentication method | `string` | `null` | no |
| secret_key | AWS secret key to use as authentication method | `string` | `null` | no |
| session_token | AWS session token to use as authentication method | `string` | `null` | no |
| cron_expression | By default, triggers the lambda function every 2 hours. Provide [CRON expression](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-schedule-expressions.html) to determine how frequently the lambda function will be invoked to copy backup to DR region(s) | `string` | `"0 0/2 * * ? *"` | no |
| cwlog_retention_days | Number of days to retain the lambda logs stored in cloudwatch log group | `number` | `90` | no |
| cwlog_kms_key | ID/ARN/Alias of KMS key to encrypt the cloudwatch log group created for lambda function | `string` | `""` | no |
| cwlog_skip_destroy | Whether to delete the log group during the destroy operation. Setting to false will only delete the log group from terraform state | `bool` | `false` | no |
| function_role_name | Name for IAM role to associate with the lambda function | `string` | `"cloudhsm-dr"` | no |
| function_name | Name for the lambda function | `string` | `"cloudhsm-dr"` | no |
| function_runtime | Lambda runtime to use for code execution | `string` | `"python3.9"` | no |
| function_memory_size | Amount of memory to allocate to the lambda function | `number` | `128` | no |
| function_timeout | Timeout to set for the lambda function | `number` | `60` | no |
| function_reserved_concurrent_executions | Amount of reserved concurrent executions for the lambda function. A value of `0` disables lambda from being triggered and `-1` removes any concurrency limitations | `number` | `-1` | no |
| function_xray_tracing_mode | Whether to sample and trace a subset of incoming requests with AWS X-Ray. **Possible values:** `PassThrough` and `Active` | `string` | `"PassThrough"` | no |
| dr_regions | Regions to copy CloudHSM backup to for DR. You can provide either a single region or multiple regions separated by comma. Example: eu-west-1, eu-west-2 | `string` | n/a | yes |
| hsm_cluster_ids | In case you want to limit backup to one or more CloudHSM cluster(s). Example: cluster-xxxxx, cluster-yyyyy | `string` | `null` | no |
| tags | Key value pair to assign to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| function_arn | ARN of the lambda function created |
| cron_expression | Interval at which the lambda function will be invoked |
| iam_role_arn | ARN of the IAM role attached to the lambda function |
