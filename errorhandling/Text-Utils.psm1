# ------------------------------------------------------------
#  Copyright (c) Microsoft Corporation.  All rights reserved.
#  Licensed under the MIT License (MIT). See License.txt in the repo root for license information.
# ------------------------------------------------------------

#.Description
# Returns a boolean indicating if PoshLog/Serilog is loaded and ready to be used
Function Confirm-LoggerIsEnabled() {
    # Checking if PoshLog/Serilog is loaded
    if (-not ([System.Management.Automation.PSTypeName]'Serilog.Log').Type) {
        return $False
    }

    $loggerType = [Serilog.Log]::Logger.GetType()

    # Check if the logger is enabled by checking the type is not SilentLogger
    if ($loggerType -eq [Serilog.Core.Logger]) {
        return $True
    }

    # Unknown, we will return false
    return $False
}

#.Description
# Cmdlet for informational messages with predefined title style formatting
# Uses Write-Host to show in the console & logging with Write-InfoLog
Function Show-Title ([string]$Text) {
    $Title = "# " + $Text.ToUpper();

    # Check if the logger is enabled
    if (Confirm-LoggerIsEnabled) {
        Write-InfoLog $Title
    } else {
        Write-Host $Title
    }
}


#.Description
# Cmdlet for informational messages
# Uses Write-Host to show in the console & logging with Write-InfoLog
Function Show-Output ([string]$Text) {
    $Output = ""
    if($Text.length -ne 0)
    {
        $Output = $Text
    }

    if (Confirm-LoggerIsEnabled) {
        Write-InfoLog $Output
    } else {
        Write-Host $Output
    }
}

#.Description
# Cmdlet for debug messages, using Write-Host to show in the console & logging with Write-DebugLog
function Show-DebugOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )

    # Log with PoshLog
    if (Confirm-LoggerIsEnabled) {
        Write-DebugLog $Message
    } else {
        Write-Debug $Output
    }
}

#.Description
# Cmdlet for warnings, using Write-Warning & logging with PoshLog
function Show-Warning {
    param(
        [Parameter(Mandatory=$true)]
        [string]$WarningMessage
    )

    # Call Write-Warning internally
    Write-Warning $WarningMessage

    # Log with PoshLog
    if (Confirm-LoggerIsEnabled) {
        Write-WarningLog $WarningMessage
    } else {
        $Output = "Warning: " + $WarningMessage
        Write-Host $Output
    }
}

#.Description
# Cmdlet for non-terminating error, using Write-Error & logging with PoshLog
function Show-Error {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ErrorMessage
    )

    # Call Write-Error internally
    Write-Error $ErrorMessage

    # Log with PoshLog
    if (Confirm-LoggerIsEnabled) {
        Write-ErrorLog $ErrorMessage
    } else {
        $Output = "ERROR: " + $ErrorMessage
        Write-Host $Output
    }
}

#.Description
# Cmdlet for terminating error, throwing terminating error & logging with PoshLog
function Show-RadFatalError {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ErrorMessage
    )

    # Log with PoshLog
    if (Confirm-LoggerIsEnabled) {
        Write-FatalLog $ErrorMessage
    } else {
        $Output = "FATAL ERROR: " + $ErrorMessage
        Write-Host $Output
    }

    throw $ErrorMessage
}

Export-ModuleMember -Function Show-Title
Export-ModuleMember -Function Show-Output
Export-ModuleMember -Function Show-DebugOutput
Export-ModuleMember -Function Show-Warning
Export-ModuleMember -Function Show-Error
Export-ModuleMember -Function Show-FatalError
Export-ModuleMember -Function Confirm-LoggerIsEnabled