# Example Data Pipeline & Infrastructure Monorepo

> **Note:** This repository is an example/template that you can clone and modify for your own project needs. It demonstrates one way to structure a project that combines application code (AWS Lambda functions) with infrastructure code (Terraform). Use this as a starting point to tailor your own workflow.

## Overview

This repository illustrates how you might organize a monorepo that contains:

- **Application Code:** A data processing pipeline implemented as AWS Lambda functions.
- **Infrastructure Code:** Terraform modules and environment configurations for deploying the infrastructure on AWS.

We use [Nx](https://nx.dev) to manage builds, tests, and deployments across multiple projects in a unified workspace.

## Repository Structure

```
├── .gitignore
├── .gitlab-ci.yml
├── LICENSE
├── README.md
├── apps
│   └── data-pipeline
│       ├── step1-lambda
│       │   ├── src/           # Lambda source code and tests
│       │   ├── project.json   # Nx project configuration for step1-lambda
│       │   └── ...            # Other build artifacts and configuration files
│       └── step2-lambda
│           ├── src/           # Lambda source code and tests
│           ├── project.json   # Nx project configuration for step2-lambda
│           └── ...            # Other build artifacts and configuration files
├── infra
│   ├── create_terraform_backend.sh  # Script to create the remote Terraform backend
│   ├── environments                 # Environment-specific Terraform configurations
│   │   ├── dev
│   │   │   ├── backend.tf
│   │   │   ├── main.tf
│   │   │   ├── project.json         # Nx project for deploying dev infra
│   │   │   └── variables.tf
│   │   ├── pre-prod
│   │   │   ├── backend.tf
│   │   │   └── main.tf
│   │   └── prod
│   │       ├── backend.tf
│   │       └── main.tf
│   └── modules                      # Reusable Terraform modules
│       ├── data-pipeline            # Modules for deploying Lambda functions
│       │   ├── step1-lambda
│       │   └── step2-lambda
│       ├── gitlab_runner_ecs        # Module for deploying a GitLab Runner on ECS
│       └── vpc                      # VPC, subnets, and networking module
├── nx                               # Nx CLI script for Unix
├── nx.bat                           # Nx CLI script for Windows
├── nx.json                          # Nx workspace configuration
├── package.json                     # Node dependencies and workspace scripts
```

## Why This Terraform Structure?

This repository uses a modular Terraform structure to promote **reusability, maintainability,** and **scalability**:

- **Environment Separation:**  
  The `infra/environments` folder contains separate configurations for each environment (dev, pre-prod, prod). This helps manage different settings, state files, and resource configurations for each stage of deployment.

- **Reusable Modules:**  
  The `infra/modules` directory includes modules for VPC, data pipeline Lambda functions, and other components. This modular approach allows you to reuse and version your infrastructure code easily across different projects.

- **Remote State Management:**  
  A dedicated script (`create_terraform_backend.sh`) is provided to create and configure an S3 bucket (with versioning and encryption) and a DynamoDB table for state locking. This ensures that your Terraform state is securely stored and that concurrent modifications are avoided.

## Gitflow & Releases

This repository follows a simplified version of the **Gitflow** branching model to support a clear release process:

- **Main Branches:**  
  - `main`: Contains production-ready code.
  - `develop`: Contains code that is ready for testing and integration in the development environment.

- **Feature Branches:**  
  Create feature branches off of `develop` for new features or bug fixes. Once completed, merge them back into `develop` via merge requests.

- **Releases:**  
  When a set of changes in `develop` is ready for production, a release branch (or tag) is created from `develop`. This branch/tag is then merged into `main` and deployed to production.

Using Gitflow ensures a stable, manageable workflow with clear separation between development, pre-production, and production environments.

## Prerequisites

Ensure you have the following installed and configured:
- **Node.js** (v20 or later) and **npm**
- **pnpm** (recommended for package management)
- **Terraform** (v1.8.0 or later)
- **AWS CLI** (with appropriate credentials)
- (Optional) **Nx CLI** installed globally (`npm install -g nx`)

## Getting Started

### Workspace Setup

1. **Initialize Nx (if not already done):**

   ```bash
   nx init
   ```

2. **Install the Python plugin:**

   ```bash
   pnpm install @nxlv/python --save-dev
   ```

3. **Review the NX configuration:**  
   See the [`nx.json`](./nx.json) file for workspace layout, generators, and shared inputs.

### Application Projects

Under `apps/data-pipeline`:
- **step1-lambda:**  
  Simulates an LLM call and returns a generated response.  
  Use its own README for additional details.

- **step2-lambda:**  
  Processes the output from step1-lambda to perform sentiment analysis.

Each project has an Nx configuration (`project.json`) that defines targets such as:
- **build** – Compile/build the Lambda code.
- **test** – Run tests using pytest.
- **zip** – Package the Lambda function for deployment.

Examples:
- **Build a project:**

  ```bash
  npx nx run data-pipeline-step1-lambda:build
  ```

- **Run tests:**

  ```bash
  npx nx run data-pipeline-step1-lambda:test
  ```

- **Create a deployment package:**

  ```bash
  npx nx run data-pipeline-step1-lambda:zip
  ```

### Infrastructure Projects

The `infra` directory contains Terraform configurations:
- **Environments:**  
  Separate folders for `dev`, `pre-prod`, and `prod` allow you to maintain different configurations and state backends.
  
- **Modules:**  
  Contains reusable modules (e.g., VPC, GitLab Runner, Lambda modules) for a consistent and repeatable deployment process.

Each environment (e.g., `infra/environments/dev`) includes its own Nx project (`project.json`) that defines targets such as:
- **deploy:** Runs Terraform commands (`init`, `plan`, `apply`) to deploy the infrastructure.
- **gitlab-runner-prerequisites:** Runs scripts to configure the Terraform backend.

### CI/CD Pipeline

The repository uses GitLab CI/CD. The `.gitlab-ci.yml` file defines two main stages:

1. **Build Stage:**  
   Uses the Node image to install dependencies and run:
   ```bash
   npx nx affected:build --base=$NX_BASE --head=$NX_HEAD
   ```
   This builds only the projects that have changed. Artifacts (e.g., Lambda deployment packages) are stored for later use.

2. **Deploy Stage (Dev):**  
   Uses a Terraform image to deploy the unified infrastructure.
   The deploy job runs the `deploy` target for the `infra-dev` project (located in `infra/environments/dev/project.json`).

Example snippet for the development deployment:

```yaml
deploy:dev:
  stage: deploy
  image: hashicorp/terraform:1.8.0
  script:
    - npm ci
    - npx nx run infra-dev:deploy --base=$NX_BASE --head=$NX_HEAD
  environment:
    name: dev
  rules:
    - if: '$CI_COMMIT_BRANCH == "develop"'
```

### Creating the Terraform Backend

Run the provided script to create the remote Terraform backend (S3 bucket and DynamoDB table):

```bash
./infra/create_terraform_backend.sh <AWS_REGION> <S3_BUCKET_NAME> <DYNAMODB_TABLE_NAME>
```

For example:

```bash
./infra/create_terraform_backend.sh us-east-1 my-terraform-state-bucket terraform-lock
```

This script will:
- Create an S3 bucket (if it doesn’t exist) with versioning and encryption enabled.
- Create a DynamoDB table for Terraform state locking.

## Deployment Workflow

1. **Make Code Changes:**  
   Develop new features or fix bugs in your Lambda functions or infrastructure code.

2. **Build & Test Locally:**  
   Use Nx commands to build, test, and package your projects.

3. **Commit & Push:**  
   Push changes to the `develop` branch. The CI pipeline will build affected projects and deploy the development infrastructure.

4. **Terraform Manual Deployment (Optional):**  
   Navigate to `infra/environments/dev` and run:
   ```bash
   terraform init
   terraform plan -out=plan.out
   terraform apply -auto-approve plan.out
   ```

## Contributing

Contributions are welcome! To contribute:
1. Fork this repository.
2. Create a new branch for your feature or bugfix.
3. Commit and push your changes.
4. Open a merge request detailing your modifications.

## License

This project is licensed under the [MIT License](./LICENSE).

## Contact

For questions or issues, please contact **rinat-akhmetov**.

---

*This repository is intended as a reference implementation and starting point for projects that require a similar monorepo structure combining application code with infrastructure as code.*