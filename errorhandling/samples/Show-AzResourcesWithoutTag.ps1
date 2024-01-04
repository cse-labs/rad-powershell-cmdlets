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

$ScriptName = $MyInvocation.MyCommand.Name

. .\Init.ps1
. .\Init-Logger.ps1 -DetailedOutput:$DetailedOutput -SilentMode:$SilentMode -ScriptName:$ScriptName

# Authenticate to Azure (you may need to log in interactively if not already authenticated)
Connect-AzAccount

# Iterate over all Azure resources
foreach ($resource in Get-AzResource) {
    # Check if the resource has tags
    if (-not $resource.Tags) {
        # Output the resource details or perform any desired action
        $resource | Select-Object ResourceId, ResourceGroupName, ResourceType, ResourceName
    }
}

# Disconnect from Azure (optional)
Disconnect-AzAccount
