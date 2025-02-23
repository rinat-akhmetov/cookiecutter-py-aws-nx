variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}
