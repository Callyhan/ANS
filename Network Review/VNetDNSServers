# Login to Azure
az login

# Get all virtual networks in the subscription
$vnetList = Get-AzVirtualNetwork

# Create an array to hold the results
$results = @()

# Loop through each virtual network
foreach ($vnet in $vnetList) {
    # Get the DNS servers for the virtual network
    $dnsServers = $vnet.DhcpOptions.DnsServers -join ","
    
    # Create a custom object with the virtual network name and DNS servers
    $result = [PSCustomObject]@{
        VNetName   = $vnet.Name
        DnsServers = $dnsServers
    }
    
    # Add the result to the array
    $results += $result
}

# Export the results to a CSV file
$results | Export-Csv -Path "VNetDnsServers.csv" -NoTypeInformation

Write-Output "DNS server information exported to VNetDnsServers.csv"
