# ------------------------------------------------------------
#  Copyright (c) Microsoft Corporation.  All rights reserved.
#  Licensed under the MIT License (MIT). See License.txt in the repo root for license information.
# ------------------------------------------------------------

#.Description
# Function to get logs path and create a folder if one does not exist
Function Get-LogDirectory {
    param (
        [string]$Module
    )
    try {
        # Get home directory of user
        if ([string]::IsNullOrEmpty($Env:USERPROFILE)) {
            $HomeDir = "~"
        } else {
            $HomeDir = $Env:USERPROFILE
        }

        $DefaultDir = "." + $Module.ToLower() + "-logs"
        $LogDir = Join-Path -Path $HomeDir -ChildPath $DefaultDir

        # Create the logs directory if it does not exist
        if (-not (Test-Path -Path $LogDir)) {
            New-Item -ItemType Directory -Path $LogDir | Out-Null
        }

        return $LogDir
    } catch {
        $ErrorMessage = Get-ErrorMessage -ErrorCode '200' -Parameters @($_)
        Show-Error $ErrorMessage
    }
}

#.Description
# Configure the default sinks
Function Get-DefaultLoggingConfiguration {
    param (
        [string]$ScriptName,
        [string]$Module,
        [string[]]$Properties
    )

    $LogDir = Get-LogDirectory -Module $Module

    $Prefix = $Module.ToLower() + '-'

    # Create a logger with default console sink and a file sink
    # Debug and higher messages will be written into file,
    # while Information and higher level messages will be written to the console by default.
    $LoggerConfig = New-Logger |
        Set-MinimumLevel -Value Debug |
        Add-SinkFile -Path (Join-Path -Path $LogDir -ChildPath ($Prefix + ".log")) -OutputTemplate '{Timestamp:HH:mm:ss} [{Level:u3}] {Properties:j} {Message:lj} {NewLine}' -RollingInterval Day

    # If script name is provided, add it to the logger properties
    if ($Null -ne $ScriptName -and $ScriptName -ne '') {
        $LoggerConfig = $LoggerConfig | Add-EnrichWithProperty -Name 'ScriptName' -Value $ScriptName
    }

    # If additional properties are provided, add them to the logger properties
    if (@{} -ne $Properties) {
        foreach ($Property in $Properties) {
            $LoggerConfig = $LoggerConfig | Add-EnrichWithProperty -Name $Property.Key -Value $Property.Value
        }
    }

    # Check if the logger configuration is not null
    if ($null -eq $LoggerConfig) {
        $ErrorMessage = Get-ErrorMessage -ErrorCode '201' -Parameters @($_)
        Show-Error $ErrorMessage
        return $null
    }

    return $LoggerConfig
}

#.Description
# Check for  custom logging config, and return default logging configuration if not found
Function Get-LoggingConfiguration {
    param (
        [string]$ScriptName,
        [string]$Module,
        [string[]]$Properties
    )

    $CustomLoggingModulePath = Join-Path -Path (Get-Location) -ChildPath "CustomLogging.psm1"

    # Check if custom logging module path exists in current directory
    if (Test-Path -Path $CustomLoggingModulePath) {
        Import-Module -Name $CustomLoggingModulePath -Force

        # Check for function named "Get-CustomLoggingConfiguration"
        if (Get-Command -Module (Get-Module -Name (Split-Path -Leaf -Path $customLoggingModulePath)) -Name "Get-CustomLoggingConfiguration" -ErrorAction SilentlyContinue) {
            return Get-CustomLoggingConfiguration
        }
    }

    # If no custom logging configuration is provided, return the default logging configuration
    return Get-DefaultLoggingConfiguration -ScriptName $ScriptName -Module $Module
}

Export-ModuleMember -Function Get-LoggingConfiguration
Export-ModuleMember -Function Get-LogDirectory
