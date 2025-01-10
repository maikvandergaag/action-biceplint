param (
    [string]$BicepFilesJson,
    [bool]$CreateSarif = $true,
    [bool]$MarkdownReport = $true,
    [string]$SarifFilePath = "bicep-lint.sarif",
    [string]$MarkdownReportFilePath = "bicep-lint-report.md"
)

BEGIN {
    Write-Host "Starting Bicep Linting"
}
PROCESS {
    $files = ConvertFrom-Json $BicepFilesJson
    
    # Create a default markdown report
    $report = @()
    $report += "## Bicep Linting Report :rocket:"

    $combinedSarif = @{
        version = "2.1.0"
        runs    = @(@{
                tool    = @{
                    driver = @{
                        name = "bicep"
                    }
                }
                results = @()
            })
    }

    if ($files.Count -eq 0) {
        $report += "No bicep files found in the commit"
    }
    else {
        foreach ($file in $files) {
            Write-Output "- Linting $file"
            $sarif = bicep lint $file --diagnostics-format sarif | ConvertFrom-Json

            foreach ($run in $sarif.runs) {
                $report += "**$($file)**"

                foreach ($result in $run.results) {
                    if ($CreateSarif) {
                        $combinedSarif.runs[0].results += $result
                    }
                        
                    $level = switch ($result.level) {
                        "error" { ":triangular_flag_on_post:" }
                        "warning" { ":warning:" }
                        default { ":information_source:" }
                    }
                    foreach ($location in $result.locations) {
                        $report += "* $($level) - **Line:** $($location.physicalLocation.region.startLine) - $($result.message.text)"
                    }
                }                
            }
        }
    }

    if ($combinedSarif -and $CreateSarif) {
        Write-Output "Creating SARIF file"
        $report += "SARIF file created: $SarifFilePath"
        $combinedSarif | ConvertTo-Json -Depth 100 | Out-File -FilePath $SarifFilePath
    }

    if ($MarkdownReport) {
        Write-Output "Creating Markdown report"
        $report += "Markdown report created: $SarifFilePath"
        $report | Out-File -FilePath $MarkdownReportFilePath
    }

    $report >> $env:GITHUB_STEP_SUMMARY
}
END {
    Write-Host "Done Bicep Linting"
}