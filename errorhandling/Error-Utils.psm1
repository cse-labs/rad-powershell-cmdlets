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

    $ErrorMessages = @{
        # 100 codes are for DAEF context errors and warnings
        '100' = "There is no [{0}] in the daef context directory [{1}]. This is expected when running context functions for the first time."
        '101' = "An error occurred while getting the daef context path: {0}"
        '102' = "The {0} directory does not exists."
        '103' = "An error occurred while listing the context paths: {0}"
        '104' = "An error occurred while switching the context: {0}"
        '105' = "An error occurred while getting the context: {0}"
        '106' = "An error occurred while writing the context: {0}"
        '107' = "An error occurred while getting the cluster object: {0}"

        # 200 codes are for DAEF logging errors
        '200' = "An error occurred while getting the logs path: {0}"
        '201' = "Failed to create logger configuration"

        # 300 codes are for Fatal errors
        '300' = "An error occurred while retrieving [{0}]. Error message: [{1}]"
        '301' = "An error occurred while creating Service Principal on Subscription {0}"
        '302' = "An error occurred while creating resource group [{0}] at location [{1}]"
        '303' = "Deployment failed with error message: {0}"
        '304' = "E4K version not found for Alice Springs version [{0}] in [{1}]"
        '305' = "An error occured while deploying IIOT App Resources: {0}"
        '306' = "An error occurred while deploying E4K [{0}] [[{1}]] in namespace [{2}]. Error message: {3}"
        '307' = "An error occurred while running kubectl apply kustomization on folder {0}"
        '308' = "An error occurred while creating Service Principal {0}"
        '309' = "An error occurred while getting the service principal object id."
        '310' = "An error occurred while initializing Dapr on AKS EE Cluster"
        '311' = "An error occurred while getting E4K and OPCUA versions from Alice Springs version [{0}] in [{1}]"
        '312' = "An error occurred while installing [{0}] version [{1}]."
        '313' = "Please make sure that the Event Hub Endpoint is set in the current context and run the script again"
        '314' = "Event Hub Endpoint update unsuccessful. Please update the {0} manifest and run the script again"
        '315' = "Docker is not running. Please start Docker and run the script again."
        '316' = "Docker is not running. {0} Please start Docker and run the script again."
        '317' = "An error occurred while logging into ACR {0}. Error message: {1}"
        '318' = "An unexpected error occurred while executing the command: [{0}]. Error message: [{1}]"
        '319' = "An error occurred while changing an az cli configuration"
        '320' = "An error occurred while starting a proxy for Cluster {0} in Resource Group {1}"
    }

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