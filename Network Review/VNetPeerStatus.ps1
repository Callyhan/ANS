# Prompt user for subscription IDs
$subscriptionIds = Read-Host -Prompt "Enter one or multiple Subscription IDs (comma-separated)"

# Split input into an array of subscription IDs
$subscriptions = $subscriptionIds -split ","

# Initialize an empty array to hold peering details
$peeringDetails = @()

# Loop through each subscription ID
foreach ($subscriptionId in $subscriptions) {
    $subscriptionId = $subscriptionId.Trim()
    
    # Set the subscription context
    Write-Host "Switching to subscription: $subscriptionId" -ForegroundColor Yellow
    Set-AzContext -SubscriptionId $subscriptionId
    
    # Get all VNets in the subscription
    $vnets = Get-AzVirtualNetwork
    
    foreach ($vnet in $vnets) {
        # Get all peerings for the VNet
        $peerings = Get-AzVirtualNetworkPeering -ResourceGroupName $vnet.ResourceGroupName -VirtualNetworkName $vnet.Name
        
        foreach ($peering in $peerings) {
            # Add peering details to the array
            $peeringDetails += [PSCustomObject]@{
                SubscriptionID   = $subscriptionId
                ResourceGroup    = $vnet.ResourceGroupName
                VNetName         = $vnet.Name
                PeeringName      = $peering.Name
                PeeringStatus    = $peering.PeeringState
                RemoteVNetName   = $peering.RemoteVirtualNetwork.Id.Split("/")[-1]
                RemoteVNetRegion = $peering.RemoteVirtualNetwork.Location
            }
        }
    }
}

# Define output CSV file name
$outputFile = "VNetPeeringStatuses.csv"

# Export peering details to a CSV file
Write-Host "Exporting peering details to $outputFile..." -ForegroundColor Green
$peeringDetails | Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "Done! The VNet peering statuses have been saved to $outputFile" -ForegroundColor Green
