# Login to Azure
Connect-AzAccount

# Prompt the user to enter subscription IDs (comma-delimited)
$subscriptionIds = Read-Host -Prompt "Enter subscription IDs (comma-delimited)"
$subscriptions = $subscriptionIds -split ','

# Create an array to hold the results
$results = @()

foreach ($subscription in $subscriptions) {
    # Set the Azure context for the subscription
    Set-AzContext -SubscriptionId $subscription.Trim()

    # Retrieve all Network Security Groups in the subscription
    $networkSecurityGroups = Get-AzNetworkSecurityGroup

    foreach ($nsg in $networkSecurityGroups) {
        # Retrieve resources associated with the NSG
        $associatedResources = (Get-AzNetworkInterface | Where-Object { $_.NetworkSecurityGroup.Id -eq $nsg.Id }).Name

        foreach ($rule in $nsg.SecurityRules) {
            # Check if the rule has "Any" for port, source, and destination
            if ($rule.Protocol -eq "*" -and $rule.SourceAddressPrefix -eq "*" -and $rule.DestinationAddressPrefix -eq "*") {
                # Add the rule details to the results array
                $results += [PSCustomObject]@{
                    SubscriptionId  = $subscription.Trim()
                    NSGName         = $nsg.Name
                    RulePriority    = $rule.Priority
                    RuleName        = $rule.Name
                    AssociatedWith  = if ($associatedResources -ne $null) { $associatedResources -join ", " } else { "None" }
                }
            }
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "PermissiveNSGRules.csv" -NoTypeInformation

Write-Host "Results exported to 'PermissiveNSGRules.csv'."
