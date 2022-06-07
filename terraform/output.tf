output "function_arn" {
  value       = aws_lambda_function.cloudhsm_dr.arn
  description = "ARN of the lambda function created"
}

output "cron_expression" {
  value       = aws_cloudwatch_event_rule.cloudhsm_dr.schedule_expression
  description = "Interval at which the lambda function will be invoked"
}

output "iam_role_arn" {
  value       = aws_iam_role.cloudhsm_dr.arn
  description = "ARN of the IAM role attached to the lambda function"
}
