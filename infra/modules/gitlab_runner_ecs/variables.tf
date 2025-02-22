variable "gitlab_runner_token" {
  description = "GitLab Runner registration token"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID for the GitLab runner"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}
variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string

}
variable "subnet_ids" {
  description = "Subnet IDs for the GitLab runner"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "development"
  }
}
