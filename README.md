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
 nx generate @nxlv/python:uv-project step1-lambda \
  --directory "data-pipeline" \
  --verbose \

 ```
