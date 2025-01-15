# Bicep Linting Github Action

This GitHub Action performs linting on Bicep files in your repository. It can check all files or only the changed files (meaning the bicep files within your commit).

The bicep cli normally generated a single SARIF file per bicep files, but this script can combine those files into one.

## Inputs

| Name                  | Type    | Description                                      | Default             |
|-----------------------|---------|--------------------------------------------------|---------------------|
| `allfiles`            | boolean | Check all files or only the changed files        | `false`             |
| `create-sarif`        | boolean | Create a combined SARIF file                     | `true`              |
| `markdown-report`     | boolean | Create a markdown report                         | `false`             |
| `sarif-output-path`   | string  | The file path to save the SARIF file             | `bicep-lint.sarif`  |
| `markdown-output-path`| string  | The file path to save the markdown report        | `bicep-lint.md`     |

## Usage

To use this action in your GitHub Actions workflow, add the following step to your workflow YAML file:

```yaml
name: Bicep Linting

on:
  push:
  workflow_dispatch:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - name: Bicep Linting
        uses: maikvandergaag/action-biceplint@v1.0.0
        with:
          allfiles: true
          create-sarif: true
          markdown-report: false
          sarif-output-path: bicep-lint.sarif
          markdown-output-path: bicep-lint.md
      - name: Upload SARIF file
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: bicep-lint.sarif
          category: bicep-linting
```
## Parameters

### `allfiles`

- **Type**: boolean
- **Description**: Determines whether to check all files or only the changed files.
- **Default**: `false`

### `create-sarif`

- **Type**: boolean
- **Description**: Determines whether to create a combined SARIF file.
- **Default**: `true`

### `markdown-report`

- **Type**: boolean
- **Description**: Determines whether to create a markdown report.
- **Default**: `false`

### `sarif-output-path`

- **Type**: string
- **Description**: The file path to save the SARIF file.
- **Default**: `bicep-lint.sarif`

### `markdown-output-path`

- **Type**: string
- **Description**: The file path to save the markdown report.
- **Default**: `bicep-lint.md`

## Example

Here is an example of how to implement this action in your GitHub Actions workflow:

```yml
name: Bicep Linting

on:
  push:
  pull_request:
  workflow_dispatch:

env:
  allFiles: ${{ github.event_name != 'pull_request' && true || ( github.base_ref == 'main' && true || false) }}

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - name: Bicep Linting
        uses: maikvandergaag/action-biceplint@v1.0.0
        with:
          allfiles: true
          create-sarif: true
          markdown-report: false
          sarif-output-path: bicep-lint.sarif
          markdown-output-path: bicep-lint.md
      ## Only needed when you want to upload the SARIF file
      - name: Upload SARIF file
        if: always()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: bicep-lint.sarif
          category: bicep-linting
```

This example demonstrates how to set up the Bicep Linting action to check all files based on the branch or github event, create a SARIF report, and upload the SARIF file to GitHub. Adjust the parameters as needed for your specific use case.
