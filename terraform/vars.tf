variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region in which you want to create resources"
}

variable "profile" {
  type        = string
  default     = null
  description = "AWS CLI profile to use as authentication method"
}

variable "access_key" {
  type        = string
  default     = null
  description = "AWS access key to use as authentication method"
}

variable "secret_key" {
  type        = string
  default     = null
  description = "AWS secret key to use as authentication method"
}

variable "session_token" {
  type        = string
  default     = null
  description = "AWS session token to use as authentication method"
}

variable "cron_expression" {
  type        = string
  default     = "0 0/2 * * ? *"
  description = "By default, triggers the lambda function every 2 hours. Provide [CRON expression](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-schedule-expressions.html) to determine how frequently the lambda function will be invoked to copy backup to DR region(s)"
}

variable "cwlog_retention_days" {
  type        = number
  default     = 90
  description = "Number of days to retain the lambda logs stored in cloudwatch log group"
}

variable "cwlog_kms_key" {
  type        = string
  default     = ""
  description = "ID/ARN/Alias of KMS key to encrypt the cloudwatch log group created for lambda function"
}

variable "cwlog_skip_destroy" {
  type        = bool
  default     = false
  description = "Whether to delete the log group during the destroy operation. Setting to false will only delete the log group from terraform state"
}

variable "function_role_name" {
  type        = string
  default     = "cloudhsm-dr"
  description = "Name for IAM role to associate with the lambda function"
}

variable "function_name" {
  type        = string
  default     = "cloudhsm-dr"
  description = "Name for the lambda function"
}

variable "function_runtime" {
  type        = string
  default     = "python3.9"
  description = "Lambda runtime to use for code execution"
}

variable "function_memory_size" {
  type        = number
  default     = 128
  description = "Amount of memory to allocate to the lambda function"
}

variable "function_timeout" {
  type        = number
  default     = 60
  description = "Timeout to set for the lambda function"
}

variable "function_reserved_concurrent_executions" {
  type        = number
  default     = -1
  description = "Amount of reserved concurrent executions for the lambda function. A value of `0` disables lambda from being triggered and `-1` removes any concurrency limitations"
}

variable "function_xray_tracing_mode" {
  type        = string
  default     = "PassThrough"
  description = "Whether to sample and trace a subset of incoming requests with AWS X-Ray. **Possible values:** `PassThrough` and `Active`"
}

variable "dr_regions" {
  type        = string
  description = "Regions to copy CloudHSM backup to for DR. You can provide either a single region or multiple regions separated by comma. Example: eu-west-1, eu-west-2"
}

variable "hsm_cluster_ids" {
  type        = string
  default     = null
  description = "In case you want to limit backup to one or more CloudHSM cluster(s). Example: cluster-xxxxx, cluster-yyyyy"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Key value pair to assign to resources"
}
