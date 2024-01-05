# ------------------------------------------------------------
#  Copyright (c) Microsoft Corporation.  All rights reserved.
#  Licensed under the MIT License (MIT). See License.txt in the repo root for license information.
# ------------------------------------------------------------
Param(
    [switch]
    [Parameter(mandatory=$False)]
    $DetailedOutput,

    [switch]
    [Parameter(mandatory=$False)]
    $SilentMode
)

if ($null -eq (Get-Module -ListAvailable -Name Az.Accounts)) {
    Install-Module -Name Az.Accounts -Scope CurrentUser -Force
}

if ($null -eq (Get-Module -ListAvailable -Name Az.Resources)) {
    Install-Module -Name Az.Resources -Scope CurrentUser -Force
}

$ScriptName = $MyInvocation.MyCommand.Name

. .\Init.ps1

Show-Title "Getting Azure Resources Without Tag"
Show-DebugOutput "Initializing logger"

. .\Init-Logger.ps1 -DetailedOutput:$DetailedOutput -SilentMode:$SilentMode -ScriptName:$ScriptName

Show-Output "Connecting to Azure"

Invoke-TerminatingCommand -Command { Connect-AzAccount } -ErrorCode 403

Show-Output "Getting Az Resources"

Invoke-TerminatingCommand -Command {
    $resources = Get-AzResource
} -ErrorCode 403

# Iterate over all Azure resources
foreach ($resource in $resources) {
    Show-DebugOutput "Processing resource $($resource.ResourceId) ..."

    # Check if the resource has tags
    if (-not $resource.Tags) {
        # Output the resource details or perform any desired action
        $resource | Select-Object ResourceId, ResourceGroupName, ResourceType, ResourceName
    }
}

# Disconnect from Azure (optional)
Show-DebugOutput "Disconnecting from azure"
Disconnect-AzAccount
