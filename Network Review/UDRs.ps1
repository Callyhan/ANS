# Prompt user for subscription IDs
$subscriptionInput = Read-Host "Enter subscription IDs (comma-separated)"
$subscriptions = $subscriptionInput -split "," | ForEach-Object { $_.Trim() }

# Connect to Azure account
Connect-AzAccount

# Initialize an array to store results
$results = @()

# Loop through each subscription
foreach ($subscriptionId in $subscriptions) {
    # Set the current subscription context
    Select-AzSubscription -SubscriptionId $subscriptionId

    # Get all virtual networks in the subscription
    $vNets = Get-AzVirtualNetwork

    foreach ($vNet in $vNets) {
        foreach ($subnet in $vNet.Subnets) {
            # Get the associated route table for the subnet
            $routeTable = Get-AzRouteTable -ResourceGroupName $vNet.ResourceGroupName | Where-Object {
                $_.Id -eq $subnet.RouteTable.Id
            }

            # Add results to the array
            $results += [PSCustomObject]@{
                SubnetName          = $subnet.Name
                VirtualNetworkName  = $vNet.Name
                ResourceGroupName   = $vNet.ResourceGroupName
                RouteTableName      = $routeTable.Name
            }
        }
    }
}

# Export results to CSV
$outputCsv = "SubnetsAndRouteTables.csv"
$results | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Output "CSV file '$outputCsv' created successfully."
