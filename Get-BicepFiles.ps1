param (
    [bool]$AllFiles = $false
)

BEGIN {
    Write-Output "Starting to get bicep files."
}PROCESS {

    if ($allFiles) {
        Write-Output "Getting all bicep and bicepparam files."
        $files = Get-ChildItem -Path . -Recurse -Include *.bicep, *.bicepparam | Select-Object -ExpandProperty FullName
    }
    else {
        Write-Output "Getting only the changed bicep and bicepparam files."
        $files = git diff HEAD~1 --name-only | Where-Object { $_ -like '*.bicep' -or $_ -like '*.bicepparam' }
    }

    $array = @()
    foreach ($file in $files) {
        $array += $file
    }

    $items = ConvertTo-Json $array -Compress
    "BICEP_FILES='$items'" >> $env:GITHUB_ENV
}END {
    Write-Output "Finished getting bicep files."
}