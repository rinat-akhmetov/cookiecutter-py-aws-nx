start with the empty nx project:

```bash
 nx init 
 ```

 install the python plugin:

 ```bash
 pnpm install @nxlv/python --save-dev
 ```

nx.json:
```json
{
  "installation": {
    "version": "20.4.1"
  },
  "plugins": [
    {
      "plugin": "@nxlv/python",
      "options": {
        "packageManager": "uv"
      }
    }
  ],
  "generators": {
    "@nxlv/python:uv-project": {
      "pyenvPythonVersion": "3.12.4",
      "pyprojectPythonDependency": ">=3.12.4",
      "publishable": false,
      "projectType": "application",
      "unitTestRunner": "pytest",
      "linter": "ruff",
      "codeCoverage": true,
      "projectNameAndRootFormat": "derived"
    }
  }
}

```bash
 nx generate @nxlv/python:uv-project data-pipeline \
  --directory apps \
  --verbose \
  --packageName data-pipeline
 ```

```bash
 nx generate @nxlv/python:uv-project step1-lambda \
  --directory "data-pipeline/lambdas" \
  --verbose \
  --packageName step1-lambda
 ```

  add a command to the zip target for aws lambda deployment:
  ```json
             "zip": {
      "executor": "nx:run-commands",
      "options": {
        "command": [
          "rm -rf tmp python lambda_deployment.zip &&",
          "uv venv .venv-dist && ",
          "source .venv-dist/bin/activate && ",
          "uv pip install dist/step1_lambda-1.0.0-py3-none-any.whl && ",
          "mkdir -p tmp/python && ",
          "cp -r .venv-dist/lib/python3.12/site-packages/* tmp/python/ && ",
          "cp -r data_pipeline_lambdas_step1_lambda/ tmp/ && ",
          "cd tmp && zip -r ../lambda_deployment.zip . && ",
          "cd .. && ",
          "rm -rf tmp .venv-dist"
        ],
        "cwd": "{projectRoot}"
      },
      "dependsOn": [
        "build"
      ]
    },
```