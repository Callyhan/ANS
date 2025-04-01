# Login to Azure
Connect-AzAccount

# Prompt the user to select one or more subscriptions
$subscriptionIds = Read-Host -Prompt "Enter subscription IDs (comma-delimited) for selection"
$subscriptions = $subscriptionIds -split ','

# Create an array to hold results
$results = @()

foreach ($subscription in $subscriptions) {
    # Set the selected subscription
    Set-AzContext -SubscriptionId $subscription.Trim()

    # Get all public IP addresses in the subscription
    $publicIPs = Get-AzPublicIpAddress

    foreach ($publicIP in $publicIPs) {
        $resourceName = if ($publicIP.IpConfiguration -ne $null) {
            $publicIP.IpConfiguration.Id.Split('/')[-3]
        } else {
            "unattached"
        }

        # Add details to the results array
        $results += [PSCustomObject]@{
            SubscriptionId = $subscription.Trim()
            PublicIpName   = $publicIP.Name
            ResourceGroup  = $publicIP.ResourceGroupName
            ResourceName   = $resourceName
            Sku            = $publicIP.Sku.Name
            IpAddress      = $publicIP.IpAddress
        }
    }
}

# Export results to a CSV file
$results | Export-Csv -Path "PublicIPDetails.csv" -NoTypeInformation

Write-Host "Results exported to 'PublicIPDetails.csv'."
