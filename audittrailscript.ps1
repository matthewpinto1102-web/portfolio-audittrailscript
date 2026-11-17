$SourceDirectory   = "C:\Users\matth\Downloads\AuditTrails\Q1_Input"
$OutputDirectory   = "C:\Users\matth\Downloads\AuditTrails\Q1_Output"
$ActionItems       = @("Bulk.Delete", "Modify.Permissions", "Move.File")
$WhitelistedUsers  = @("scdm-autobot-one")
$OffHoursStart     = 19
$OffHoursEnd       = 6

if (!(Test-Path -Path $OutputDirectory)) {
    New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
}

$StartTime = Get-Date
$SummaryLogPath = Join-Path $OutputDirectory "Audit_Summary_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

$FilesScanned = 0
$LinesScanned = 0
$LinesExported = 0
$MaxRowsPerFile = 1000000
$CurrentFileIndex = 1
$CurrentRowCount = 0

function Get-OutputWriter {
    param($Index)
    $OutFileName = "Consolidated_Audit_Report_Part$Index.csv"
    $OutFilePath = Join-Path $OutputDirectory $OutFileName
    $Writer = New-Object System.IO.StreamWriter($OutFilePath, $false, [System.Text.Encoding]::UTF8)
    return @{ Writer = $Writer; Path = $OutFilePath }
}

$CurrentWriterInfo = Get-OutputWriter -Index $CurrentFileIndex
$Writer = $CurrentWriterInfo.Writer
$HeaderWritten = $false

$Subsystems = Get-ChildItem -Path $SourceDirectory -Directory
foreach ($Subsystem in $Subsystems) {
    $CsvFiles = Get-ChildItem -Path $Subsystem.FullName -Filter "*.csv"
    $TotalFiles = $CsvFiles.Count
    $FileIndex = 0

    foreach ($File in $CsvFiles) {
        $FileIndex++
        $FilesScanned++
        $PercentComplete = [math]::Round(($FileIndex / $TotalFiles) * 100)
        
        Write-Progress -Activity "Scanning Subsystem: $($Subsystem.Name)" -Status "Processing file $FileIndex of $TotalFiles ($PercentComplete%)" -PercentComplete $PercentComplete

        try {
            $CsvData = Import-Csv -Path $File.FullName
        } catch {
            continue
        }

        $LineNumber = 0
        foreach ($Row in $CsvData) {
            $LineNumber++
            $LinesScanned++

            $Username = $Row.Username
            $Action = $Row.Action
            $TimestampStr = $Row.Timestamp

            $FlagReasons = @()
            $IsWhitelisted = $WhitelistedUsers -contains $Username

            if (-not $IsWhitelisted) {
                if ($ActionItems -contains $Action) {
                    $FlagReasons += "Critical Action Item ($Action)"
                }

                if ($TimestampStr -as [DateTime]) {
                    $Timestamp = [DateTime]$TimestampStr
                    $Hour = $Timestamp.Hour
                    $DayOfWeek = $Timestamp.DayOfWeek

                    $IsWeekend = ($DayOfWeek -eq 'Saturday' -or $DayOfWeek -eq 'Sunday')
                    $IsOffHour = ($Hour -ge $OffHoursStart -or $Hour -lt $OffHoursEnd)

                    if ($IsWeekend) { $FlagReasons += "Weekend Activity ($DayOfWeek)" }
                    if ($IsOffHour) { $FlagReasons += "Off-Hours Activity ($Hour:00)" }
                }
            }

            $FinalFlagReason = if ($FlagReasons.Count -gt 0) { $FlagReasons -join "; " } else { "Approved" }
            $SourceLocation = "$($Subsystem.Name)\$($File.Name) : Line $LineNumber"

            $RowProperties = [ordered]@{}
            foreach ($Property in $Row.psobject.properties.Name) {
                $RowProperties[$Property] = $Row.$Property
            }
            $RowProperties["FlagReason"] = $FinalFlagReason
            $RowProperties["SourceLocation"] = $SourceLocation

            $NewObj = [PSCustomObject]$RowProperties

            if ($CurrentRowCount -ge $MaxRowsPerFile) {
                $Writer.Flush()
                $Writer.Dispose()
                $CurrentFileIndex++
                $CurrentWriterInfo = Get-OutputWriter -Index $CurrentFileIndex
                $Writer = $CurrentWriterInfo.Writer
                $HeaderWritten = $false
                $CurrentRowCount = 0
            }

            if (-not $HeaderWritten) {
                $HeaderLine = ($NewObj.psobject.properties.Name -join ",")
                $Writer.WriteLine($HeaderLine)
                $HeaderWritten = $true
            }

            $Values = foreach ($Prop in $NewObj.psobject.properties.Name) {
                '"' + ([string]$NewObj.$Prop).Replace('"', '""') + '"'
            }
            $Writer.WriteLine($Values -join ",")
            $LinesExported++
            $CurrentRowCount++
        }
    }
}

if ($Writer) {
    $Writer.Flush()
    $Writer.Dispose()
}

Write-Progress -Activity "Scanning Subsystem" -Completed
$EndTime = Get-Date
$Runtime = $EndTime - $StartTime

$SummaryContent = "==================================================" + [Environment]::NewLine +
"AUDIT TRAIL PROCESSING SUMMARY REPORT" + [Environment]::NewLine +
"==================================================" + [Environment]::NewLine +
"Start Time       : $StartTime" + [Environment]::NewLine +
"Finish Time      : $EndTime" + [Environment]::NewLine +
"Total Runtime    : $($Runtime.ToString())" + [Environment]::NewLine +
"Source Path      : $SourceDirectory" + [Environment]::NewLine +
"Output Path      : $OutputDirectory" + [Environment]::NewLine +
"Files Scanned    : $FilesScanned" + [Environment]::NewLine +
"Lines Scanned    : $LinesScanned" + [Environment]::NewLine +
"Lines Exported   : $LinesExported" + [Environment]::NewLine +
"Off-Hours Range  : $OffHoursStart:00 - $OffHoursEnd:00" + [Environment]::NewLine +
"Action Items     : $($ActionItems -join ', ')" + [Environment]::NewLine +
"Whitelisted Bots : $($WhitelistedUsers -join ', ')" + [Environment]::NewLine +
"=================================================="

Set-Content -Path $SummaryLogPath -Value $SummaryContent
Write-Host "Audit processing completed successfully. Summary saved to $SummaryLogPath"