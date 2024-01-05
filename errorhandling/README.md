# Error Handling in RAD PowerShell Cmdlets

## Overview

The **Robust Adaptive Dynamic (RAD) PowerShell Cmdlets** include a robust error handling mechanism to enhance the reliability and adaptability of your PowerShell scripts.
Error handling is a crucial aspect of script development, ensuring graceful response to unexpected situations and effective troubleshooting.

## Key Components

### Rad-Error-Utils Module

### 1. **`Get-RadErrorMessage`**
   - Retrieve detailed error information for comprehensive troubleshooting.

### 2. **`Format-RadErrorMessage`**
   - Consistently format error messages to improve readability and maintainability.

### 3. **`Import-RadErrorsFromYaml`**
   - Imports a dictionary of errors from a yaml file.

### 4. **`Get-RadErrorMessages`**
   - List all loaded and available error messages by error code.

### 5. **`Invoke-TerminatingCommand`**
   - Execute a command and terminate the script gracefully upon command failure.

### 6. **`Set-RadErrorMessages`**
   - Add additional error messages or overwrite existing error messages.

### Rad-Text-Utils Module

### 1. **`Confirm-LoggerIsEnabled`**
   - Check if the logger is enabled before logging messages, ensuring efficient resource usage.

### 2. **`Show-Title`, `Show-Output`, `Show-DebugOutput`, `Show-Warning`, `Show-Error`, `Show-FatalError`**
   - Display messages of various types to keep users informed about script progress and issues. If logger is enabled it uses PoshLog, otherwise gracefully fallback to `Write-Host`.

## Polyglot Documentation

For in-depth explanations, examples, and usage scenarios, refer to the comprehensive polyglot documentation [here](./logging-functions.ipynb).
The polyglot documentation provides detailed insights into leveraging error handling capabilities and maximizing the potential of RAD PowerShell Cmdlets in various programming languages.

**Note:** This README serves as a quick overview. Detailed documentation can be found in the polyglot guide linked above.

In order to run the Polyglot documentation, you need to install the following dependencies:

   - [Polyglot Notebook VSCode Extension](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.dotnet-interactive-vscode)
   - [.NET Version 8.0 or higher](https://dotnet.microsoft.com/download/dotnet/8.0)

This repo is set up with a devcontainer that will automatically install the dependencies and is ready to be used. You can open it with [Visual Studio Code](https://code.visualstudio.com/docs/devcontainers/containers) or [GitHub Codespaces](https://github.com/features/codespaces).
