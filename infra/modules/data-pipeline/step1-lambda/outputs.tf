output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.step1_lambda.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.step1_lambda.arn
}

output "role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}
