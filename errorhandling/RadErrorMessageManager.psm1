class RadErrorMessageManager {
    # Static property to store error codes
    static [System.Collections.Generic.Dictionary[string, string]] $ErrorMessages = @{
        "101" = "Error 102: Invalid parameter: {0}. Expected: {1}. Actual: {2}."
        "500" = "An unexpected error occurred while executing the command: [{0}]. Error message: [{1}]"
    }

    # Static method to override error codes from a YAML file
    static [void] LoadErrorCodesFromYaml($yamlFilePath) {
        try {
            $yamlContent = Get-Content -Path $yamlFilePath -Raw | ConvertFrom-Yaml
            if ($yamlContent -is [System.Collections.Hashtable]) {
                [RadErrorMessageManager]::ErrorMessages = $yamlContent
            } else {
                Write-Host "Invalid YAML format. Expected a hashtable."
            }
        } catch {
            Write-Host "Error reading YAML file: $_"
        }
    }
}

# Example usage
# ErrorManager::LoadErrorCodesFromYaml("C:\Path\To\Your\ErrorCodes.yaml")
# Write-Host "Error Message: $($ErrorManager::$ErrorMessages['100'])"
