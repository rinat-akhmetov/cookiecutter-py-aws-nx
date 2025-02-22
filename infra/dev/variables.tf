

variable "gitlab_runner_token" {
  description = "The GitLab Runner registration token"
  type        = string
  default     = "your-gitlab-runner-registration-token"
}


variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "your-project-name"
}

variable "environment" {
  description = "The environment (e.g., development, staging, production)"
  type        = string
  default     = "development"

}

variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}
