# Function to scan a range of IP addresses
function Scan_IPRange {
    param(
        [string]$StartIPv4Address,
        [string]$EndIPv4Address
    )
    return .\Scripts\IPv4NetworkScan.ps1 -StartIPv4Address $StartIPv4Address -EndIPv4Address $EndIPv4Address -EnableMACResolving -Verbose:$false
}

# Function to insert Aal name column to each line in scan result
function Add-AalNameColumn {
    param (
        [array]$ScanResults,
        [string]$AalName
    )

    $resultsWithAalName = @()

    # Iterate through each scan result
    foreach ($result in $ScanResults) {
        # Add Aal name as the first column
        $resultWithAalName = [PSCustomObject]@{
            'AalName' = $AalName
            'IPv4Address' = $result.IPv4Address
            'Status' = $result.Status
            'Hostname' = $result.Hostname
            'MAC' = $result.MAC
            'Vendor' = $result.Vendor -replace '[^\w\s]', ''
        }
        # Add the result with Aal name to the array
        $resultsWithAalName += $resultWithAalName
    }

    return $resultsWithAalName
}

# Get the current date and time
$currentDateTime = Get-Date
Write-Host $currentDateTime

# Read JSON file
$jsonData = Get-Content -Raw -Path "Scripts/settings.json" | ConvertFrom-Json

# Read output csv Delimiter  :
$Delimiter = $jsonData.delimiter

# Read PingCount  :
$PingCount = $jsonData.PingCount

# List to store successful Aals
$successfulAals = @()
# List to store unsuccessful Aals
$unsuccessfulAals = @()

# Loop through each "Aal" in the JSON data
foreach ($Aal in $jsonData.Aals) {
    $Aalname = $Aal.name
    $firstAddress = $Aal.firstAddress

    # Ping the first address of the Aal
    $pingResult = Test-Connection -Computername $firstAddress -Count $PingCount -Quiet

    # Check if ping is successful
    if (-not $pingResult) {
        Write-Host "* $Aalname KO"
        # Add the unsuccessful Aal name to the list
        $unsuccessfulAals += $Aal.name
    }
    else {
        # Add the successful Aal to the list
        $successfulAals += $Aal
    }
}

# Array to store all scan results
$allScanResults = @()

# Scan ranges of successful Aals
foreach ($Aal in $successfulAals) {
    $startAddress = $Aal.firstAddress
    $endAddress = $Aal.lastAddress
    Write-Host "Scanning  $($Aal.name) ($startAddress - $endAddress)..."
    $scanResult = Scan_IPRange -StartIPv4Address $startAddress -EndIPv4Address $endAddress

    # Add Aal name column to scan results
    $scanResult = Add-AalNameColumn -ScanResults $scanResult -AalName $Aal.name

    # Output scan result as table
    $scanResult | Format-Table -AutoSize

    # Add scan result to the array
    $allScanResults += $scanResult
}


# Convert the current date and time to a string format
$currentDateTimeString = $currentDateTime.ToString("yyyy-MM-dd HH:mm:ss")



############ Save successful scan results to CSV file ###########

# Append the scan results to the CSV file
$allScanResults | Export-Csv -Path "scan_results.csv" -NoTypeInformation -Force -Delimiter $Delimiter

# Append the current date and time to the CSV file
$currentDateTimeString | Out-File -FilePath "scan_results.csv" -Encoding utf8 -Append



############ Save UNsuccessful Aals to CSV file ###########


# Concatenate the current date and time with the list of unsuccessful Aal names
$namesString = "$currentDateTimeString`n$($unsuccessfulAals -join $Delimiter)"

# Export the concatenated string to a CSV file
$namesString | Out-File -FilePath "unsuccessful_aals.csv" -Encoding utf8


pause
