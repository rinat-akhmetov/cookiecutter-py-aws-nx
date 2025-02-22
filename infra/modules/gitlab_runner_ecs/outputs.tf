output "cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.gitlab_runner.arn
}

output "service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.gitlab_runner.name
}

output "task_definition_arn" {
  description = "The ARN of the task definition"
  value       = aws_ecs_task_definition.gitlab_runner.arn
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.gitlab_runner.id
}