param (
    [Parameter(Mandatory = $true)]
    [PSCustomObject[]]$TweetDataArray
)

if ($TweetDataArray.Count -eq 0) {
    Write-Warning "No transactional tweet object records passed for export processing."
    return
}

$ExportDirectory = Join-Path $PSScriptRoot "ScrapedData"
if (-not (Test-Path $ExportDirectory)) {
    New-Item -ItemType Directory -Path $ExportDirectory | Out-Null
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$CsvPath = Join-Path $ExportDirectory "X_Bookmarks_Export_$Timestamp.csv"

# Pipeline data into structured CSV format sheets natively compatible with Excel
$TweetDataArray | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding utf8

Write-Host "[SUCCESS] Scraped dataset matrix exported successfully into localized data asset: $CsvPath" -ForegroundColor Gold
