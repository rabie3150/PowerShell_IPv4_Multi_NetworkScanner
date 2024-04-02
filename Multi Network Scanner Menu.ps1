# Welcome message
echo "Welcome to PowerShell Multi Network Scanner"

# Menu options
echo "1. Scan Sites"
echo "2. Scan a specific network"
echo "3. Exit"

# Prompt for user choice
$choice = Read-Host "Enter your choice (1, 2, or 3)"

# Process user choice
switch ($choice) {
    '1' {
        # Scan AALs
        echo "Scanning Sites..."
        powershell -noexit -nologo -executionpolicy bypass -File "./Scripts/SitesScanner.ps1"
		pause
    }
	'2' {
		# Prompt for network details
		$IPv4Address = Read-Host "Enter the IPv4 network address (e.g., 192.168.100.0)"
		$CIDR = Read-Host "Enter the CIDR notation (e.g., 24)"
		
		# Scan specific network
		echo "Scanning network $IPv4Address/$CIDR..."
		powershell -Command "&{.\Scripts\IPv4NetworkScan.ps1 -IPv4Address '$IPv4Address' -CIDR $CIDR -EnableMACResolving | Export-Csv -Path '.\NetworkScanResults.csv' -NoTypeInformation}"

		# Display the result in the terminal
		echo "Network Scan Results:"
		Import-Csv -Path '.\NetworkScanResults.csv'| Format-Table -AutoSize

		# Pause after displaying the result
		pause
	}
    '3' {
        # Exit
        echo "Exiting..."
        exit
    }
    default {
        # Invalid choice
        echo "Invalid choice. Please enter 1, 2, or 3."
    }
}
