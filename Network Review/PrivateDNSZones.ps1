$subscriptions = @(
    "subscription-id-1",
    "subscription-id-2",
    "subscription-id-3"
)

# Output CSV file path
$outputCsv = "PrivateDNSZonesReport.csv"

# Initialize an array to store the results
$results = @()

# Loop through each subscription
foreach ($subscriptionId in $subscriptions) {
    # Set the current subscription context
    Set-AzContext -SubscriptionId $subscriptionId

    # Get the private DNS zones in the current subscription
    $dnsZones = Get-AzPrivateDnsZone

    # Check if there are any DNS zones
    if ($dnsZones) {
        foreach ($zone in $dnsZones) {
            $results += [PSCustomObject]@{
                SubscriptionId = $subscriptionId
                ZoneName       = $zone.Name
                ResourceGroup  = $zone.ResourceGroupName
            }
        }
    } else {
        $results += [PSCustomObject]@{
            SubscriptionId = $subscriptionId
            ZoneName       = "No Private DNS Zones"
            ResourceGroup  = "N/A"
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Output "Report generated: $outputCsv"
