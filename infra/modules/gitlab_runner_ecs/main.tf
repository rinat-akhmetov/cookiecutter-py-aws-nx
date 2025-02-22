resource "aws_ecs_cluster" "gitlab_runner" {
  name = "gitlab-runner-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

resource "aws_ecs_task_definition" "gitlab_runner" {
  family                   = "gitlab-runner-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "gitlab-runner"
      image     = "gitlab/gitlab-runner:latest"
      essential = true
      environment = [
        {
          name  = "REGISTER_NON_INTERACTIVE",
          value = "true"
        },
        {
          name  = "RUNNER_TOKEN",
          value = var.gitlab_runner_token
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.gitlab_runner.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "gitlab-runner"
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_ecs_service" "gitlab_runner" {
  name            = "gitlab-runner-${var.environment}"
  cluster         = aws_ecs_cluster.gitlab_runner.id
  task_definition = aws_ecs_task_definition.gitlab_runner.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.gitlab_runner.id]
    assign_public_ip = true
  }

  tags = var.tags
}

resource "aws_security_group" "gitlab_runner" {
  name        = "gitlab-runner-${var.environment}"
  description = "Security group for GitLab Runner"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "gitlab_runner" {
  name              = "/ecs/gitlab-runner-${var.environment}"
  retention_in_days = 30

  tags = var.tags
}

resource "aws_iam_role" "ecs_execution" {
  name = "gitlab-runner-execution-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name = "gitlab-runner-task-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

data "aws_region" "current" {}
