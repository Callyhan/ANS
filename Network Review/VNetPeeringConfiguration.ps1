# Login to Azure
Update-AzConfig -DefaultSubscriptionForLogin 'XXXX-XXXX-XXXX-XXXX-XXXX'

Connect-AzAccount

# Prompt the user to enter subscription IDs (comma-delimited)
$subscriptionIds = Read-Host -Prompt "Enter subscription IDs (comma-delimited)"
$subscriptions = $subscriptionIds -split ','

# Create an array to hold the results
$results = @()

foreach ($subscription in $subscriptions) {
    # Set the context to the subscription
    Set-AzContext -SubscriptionId $subscription.Trim()

    # Get all virtual networks in the subscription
    $vnets = Get-AzVirtualNetwork

    foreach ($vnet in $vnets) {
        # Get the peering settings for each virtual network
        $peerings = $vnet.VirtualNetworkPeerings

        foreach ($peering in $peerings) {
            # Add the peering details to the results
            $results += [PSCustomObject]@{
                SubscriptionId            = $subscription.Trim()
                VNetName                  = $vnet.Name
                ResourceGroup             = $vnet.ResourceGroupName
                PeeringName               = $peering.Name
                AllowForwardedTraffic     = $peering.AllowForwardedTraffic
                AllowGatewayTransit       = $peering.AllowGatewayTransit
                UseRemoteGateways         = $peering.UseRemoteGateways
                AllowVirtualNetworkAccess = $peering.AllowVirtualNetworkAccess
            }
        }
    }
}

# Export results to a CSV file
$results | Export-Csv -Path "VNetPeeringDetails.csv" -NoTypeInformation

Write-Host "Results exported to 'VNetPeeringDetails.csv'."
