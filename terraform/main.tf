data "aws_caller_identity" "current" {}

locals {
  account_id           = data.aws_caller_identity.current.account_id
  lambda_assume_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role" "cloudhsm_dr" {
  name                  = var.function_role_name
  assume_role_policy    = local.lambda_assume_policy
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_role_policy" "cloudhsm_dr" {
  name = var.function_role_name
  role = aws_iam_role.cloudhsm_dr.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "cloudhsm:DescribeBackups",
          "cloudhsm:CopyBackupToRegion"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "cloudhsm_dr_logs" {
  role       = aws_iam_role.cloudhsm_dr.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_event_rule" "cloudhsm_dr" {
  name        = "CloudHSMDR"
  description = "Triggers a lambda function periodically that copys CloudHSM backup(s) to another region(s)"
  is_enabled  = true

  schedule_expression = "cron(${var.cron_expression})"
}

resource "aws_cloudwatch_event_target" "cloudhsm_dr" {
  rule      = aws_cloudwatch_event_rule.cloudhsm_dr.name
  target_id = "TriggerCloudHSMDR"
  arn       = aws_lambda_function.cloudhsm_dr.arn
}

resource "aws_lambda_permission" "cloudhsm_dr" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudhsm_dr.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudhsm_dr.arn
}

resource "aws_lambda_function" "cloudhsm_dr" {
  # checkov:skip=CKV_AWS_50: Enabling X-Ray tracing depends on user
  # checkov:skip=CKV_AWS_115: Setting reserved concurrent execution depends on user
  # checkov:skip=CKV_AWS_116: DLQ not required
  # checkov:skip=CKV_AWS_117: VPC deployment not required
  # checkov:skip=CKV_AWS_173: Environment variables encryption not required
  function_name    = var.key_creator_function_name
  description      = "Copy CloudHSM backup to another region"
  role             = aws_iam_role.cloudhsm_dr.arn
  filename         = data.archive_file.backup.output_path
  source_code_hash = data.archive_file.backup.output_base64sha256
  handler          = "backup.handler"
  runtime          = var.function_runtime

  memory_size                    = var.function_memory_size
  timeout                        = var.function_timeout
  reserved_concurrent_executions = var.function_reserved_concurrent_executions

  tracing_config {
    mode = var.function_xray_tracing_mode
  }

  environment {
    variables = {
      DR_REGIONS      = var.dr_regions
      HSM_CLUSTER_IDS = var.hsm_cluster_ids
    }
  }

  tags = var.tags
}
