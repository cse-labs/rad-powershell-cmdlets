# ------------------------------------------------------------
#  Copyright (c) Microsoft Corporation.  All rights reserved.
#  Licensed under the MIT License (MIT). See License.txt in the repo root for license information.
# ------------------------------------------------------------

Param(
  [switch]
  [Parameter(mandatory = $False)]
  $DetailedOutput,

  [switch]
  [Parameter(mandatory = $False)]
  $SilentMode,

  [string]
  [Parameter(mandatory=$False)]
  $ScriptName = "utils"
)

Close-Logger

# Silent mode overrrides others
if ($SilentMode) {
    Get-LoggingConfiguration -ScriptName $ScriptName -DaefContext $DaefContext |
        Start-Logger
} else {
    if (-not $DetailedOutput) {
        $LogLevel = "Information"
    } else {
        $LogLevel = "Verbose"
    }
    Get-LoggingConfiguration -ScriptName $ScriptName -DaefContext $DaefContext |
            Add-SinkConsole -RestrictedToMinimumLevel $LogLevel |
            Start-Logger
}
