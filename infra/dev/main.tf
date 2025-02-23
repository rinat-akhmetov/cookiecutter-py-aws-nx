provider "aws" {
  region = "us-east-1"
  # (Optionally configure AWS profile or leave for environment variables)
}

# Backend configuration is in backend.tf (for remote state in S3/Dynamo, not shown here)

module "network" {
  source = "../modules/vpc"

  vpc_cidr            = "10.0.0.0/16"
  vpc_name            = "gitlab-vpc"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  public_subnet_az    = "us-east-1a"
  private_subnet_az   = "us-east-1b"
  public_subnet_name  = "gitlab-public-subnet"
  private_subnet_name = "gitlab-private-subnet"
}

module "gitlab_runner" {
  source = "../modules/gitlab_runner_ecs"

  environment         = var.environment
  aws_region          = var.aws_region
  gitlab_runner_token = var.gitlab_runner_token
  vpc_id              = module.network.vpc_id
  # Use the correct output from the VPC module (see next step)
  subnet_ids = [module.network.private_subnet_id]

  tags = {
    Name = "gitlab-runner"
  }

}

module "step1_lambda" {
  source = "../modules/data-pipeline/step1-lambda"

  environment = var.environment
  environment_variables = {
    ENV = var.environment
  }
}
module "step2_lambda" {
  source = "../modules/data-pipeline/step2-lambda"

  environment = var.environment
  environment_variables = {
    ENV = var.environment
  }
}
