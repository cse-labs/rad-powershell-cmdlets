# ------------------------------------------------------------
#  Copyright (c) Microsoft Corporation.  All rights reserved.
#  Licensed under the MIT License (MIT). See License.txt in the repo root for license information.
# ------------------------------------------------------------

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Installing pre-reqs
if ($null -eq (Get-Module -ListAvailable -Name powershell-yaml)) {
    Install-Module -Name powershell-yaml -Scope CurrentUser -Force
}

if ($null -eq (Get-Module -ListAvailable -Name Az)) {
    Install-Module -Name Az -Force -AllowClobber -Scope CurrentUser
}

# Loading RAD modules
Import-Module -Name "$scriptDirectory\..\cmdlets\Rad-Error-Utils.psm1" -Force
Import-Module -Name "$scriptDirectory\..\cmdlets\Rad-Text-Utils.psm1" -Force
Import-Module -Name "$scriptDirectory\..\cmdlets\Rad-Logging-Utils.psm1" -Force

# Install and import the Azure PowerShell module
Import-Module Az