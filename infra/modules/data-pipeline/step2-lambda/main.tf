resource "aws_lambda_function" "step2_lambda" {
  filename         = "${path.module}/../../../../apps/data-pipeline/step2-lambda/lambda_deployment.zip"
  source_code_hash = filebase64sha256("${path.module}/../../../../apps/data-pipeline/step2-lambda/lambda_deployment.zip")
  function_name    = "${var.environment}-step2-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "src.app.handler"
  runtime          = "python3.12"
  timeout          = 300
  memory_size      = 256
  environment {
    variables = var.environment_variables
  }
  tags = {
    Environment = var.environment
    Project     = "data-pipeline"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.environment}-step2-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.step2_lambda.function_name}"
  retention_in_days = 14
}
