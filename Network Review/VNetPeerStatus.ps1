# Login to Azure
Write-Output "Logging into Azure..."
az login
Write-Output "Login successful."

# Define the subscriptions you want to check
$subscriptions = @("Subscription1", "Subscription2")

# Define the output CSV file
$outputCsv = "VNetPeersStatus.csv"

# Initialize an array to hold the results
$results = @()

# Loop through each subscription
foreach ($subscription in $subscriptions) {
    # Set the current subscription
    az account set --subscription $subscription

    # Get all VNETs in the current subscription
    $vnets = az network vnet list --query "[].{Name:name, ResourceGroup:resourceGroup}" -o json | ConvertFrom-Json

    # Loop through each VNET
    foreach ($vnet in $vnets) {
        # Get all peerings for the current VNET
        $peerings = az network vnet peering list --resource-group $vnet.ResourceGroup --vnet-name $vnet.Name --query "[].{Name:name, Status:peeringState}" -o json | ConvertFrom-Json

        # Loop through each peering and add the result to the array
        foreach ($peering in $peerings) {
            $results += [pscustomobject]@{
                Subscription = $subscription
                VNetName = $vnet.Name
                ResourceGroup = $vnet.ResourceGroup
                PeeringName = $peering.Name
                PeeringStatus = $peering.Status
            }
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Output "VNet peers status has been exported to $outputCsv"
