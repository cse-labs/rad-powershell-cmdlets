<#
.SYNOPSIS
    Returns a formatted error message based on the provided error code and parameters.

.DESCRIPTION
    The Get-ErrorMessage function takes an error code and an array of parameters as input.
    It uses the error code to look up a corresponding error message template, and then replaces placeholders in the template with the provided parameters.
    If the error code requires parameters and they are not provided, the function throws an error.
    If the error code is not found, the function returns null.

.PARAMETER ErrorCode
    The error code used to look up the error message template.

.PARAMETER Parameters
    The parameters used to replace placeholders in the error message template.

.EXAMPLE
    PS C:\> Get-ErrorMessage -ErrorCode '100' -Parameters @('C:\daef')
    Returns: "Error 100: There is no default.json in the daef context directory [C:\daef]"
#>
function Get-RadErrorMessage {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ErrorCode,

        [Parameter(Mandatory=$false)]
        [string[]]$Parameters
    )

    $ErrorMessages = $RadErrorMessageManager::$ErrorMessages

    if ($ErrorMessages.ContainsKey($ErrorCode)) {
        $formattedMessage = Format-ErrorMessage -Template $ErrorMessages[$ErrorCode] -Parameters $Parameters
        return "Error ${ErrorCode}: $formattedMessage"
    } else {
        return "An unexpected error occurred while executing the command: [{0}]. Error message: [{1}]"
    }
}

#.Description
# Formats error message template with the provided parameters
function Format-RadErrorMessage {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Template,

        [Parameter(Mandatory=$false)]
        [string[]]$Parameters
    )

    # Count the number of placeholders in the template
    $placeholderCount = ([regex]::Matches($Template, "{\d+}")).Count

    # Check if the number of parameters matches the number of placeholders
    if ($placeholderCount -gt 0 -and ($null -eq $Parameters -or $Parameters.Count -lt $placeholderCount)) {
        throw "Error: The template requires $placeholderCount parameters, but only $($Parameters.Count) were provided."
    }

    $formattedMessage = $Template -f $Parameters

    return $formattedMessage
}

#.Description
# Executes a command that may cause a termonating error and performs an error handling if needed.
function Invoke-TerminatingCommand {
    param (
        [Parameter(Mandatory=$true)]
        [scriptblock]$Command,

        [Parameter(Mandatory=$true)]
        [string]$ErrorCode,

        [Parameter(Mandatory=$false)]
        [string[]]$ErrorParameters
    )

    try {
        Show-Output "Executing Command: [$Command]"
        $Result = & $Command

        # Check the execution status of the command
        if ($LASTEXITCODE -ne 0) {
            $ErrorParameters+= ${Result}
            Show-FatalError (Get-ErrorMessage -ErrorCode $ErrorCode -Parameters @($ErrorParameters))
        }
        else {
            Show-Output "Command executed successfully."
            return $Result
        }
    }
    catch {
        if ($_ -like "*Error $ErrorCode*") {
            throw $_
        } else {
            Show-FatalError (Get-ErrorMessage -ErrorCode '500' -Parameters @($Command, $_))
        }
    }
}

Export-ModuleMember -Function Get-ErrorMessage
Export-ModuleMember -Function Format-ErrorMessage
Export-ModuleMember -Function Invoke-TerminatingCommand