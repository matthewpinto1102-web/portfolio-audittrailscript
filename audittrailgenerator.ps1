<#
.SYNOPSIS
    Synthetic Audit Trail Test Data Generator
.DESCRIPTION
    Creates the required directory structure under C:\Users\matth\Downloads\AuditTrails (four subsystems) 
    and generates sample CSV log files populated with normal activity, whitelisted bot 
    transactions, off-hour timestamps, and GxP red-flag action items for testing the audit script.
#>

# Root directory updated to your Downloads folder
$BaseDirectory = "C:\Users\matth\Downloads\AuditTrails\Q1_Input"

# Define the 4 Seven Bridges application subsystems
$Subsystems = @("Subsystem_Alpha", "Subsystem_Beta", "Subsystem_Gamma", "Subsystem_Delta")

# Sample data pools for generation
$Users = @("jdoe", "asmith", "bwayne", "scdm-autobot-one", "tkent", "dprince")
$Actions = @("Read.File", "View.Record", "Update.Metadata", "Bulk.Delete", "Modify.Permissions", "Move.File", "Export.Log")

Write-Host "Starting synthetic dataset generation in Downloads directory..."

foreach ($Subsystem in $Subsystems) {
    $SubsystemPath = Join-Path $BaseDirectory $Subsystem
    
    # Create subsystem directory if it doesn't exist
    if (!(Test-Path -Path $SubsystemPath)) {
        New-Item -ItemType Directory -Force -Path $SubsystemPath | Out-Null
    }

    # Generate a sample set of daily CSV files (e.g., 5 files per subsystem for demonstration)
    for ($Day = 1; $Day -le 5; $Day++) {
        $FileName = "Day_$($Day.ToString('00')).csv"
        $FilePath = Join-Path $SubsystemPath $FileName

        $CsvContent = [System.Collections.Generic.List[string]]::new()
        $CsvContent.Add("Timestamp,Username,Action,Details")

        # Generate 150 rows per file
        for ($Row = 1; $Row -le 150; $Row++) {
            # Randomize date/time across normal hours and off-hours
            $RandomDay = Get-Date -Day $Day -Month 1 -Year 2026
            $RandomHour = Get-Random -Minimum 0 -Maximum 24
            $RandomMinute = Get-Random -Minimum 0 -Maximum 60
            $Timestamp = $RandomDay.AddHours($RandomHour).AddMinutes($RandomMinute).ToString("yyyy-MM-dd HH:mm:ss")

            $RandomUser = $Users | Get-Random
            $RandomAction = $Actions | Get-Random
            $Details = "Sample transaction record $Row for $RandomAction"

            $CsvContent.Add("$Timestamp,$RandomUser,$RandomAction,$Details")
        }

        Set-Content -Path $FilePath -Value $CsvContent
    }
}

Write-Host "Synthetic dataset successfully generated at $BaseDirectory"