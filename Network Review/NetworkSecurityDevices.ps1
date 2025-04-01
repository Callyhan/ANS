# Import Azure PowerShell module
Import-Module Az

# Log in to Azure account
Connect-AzAccount

# Prompt for subscription IDs
$subscriptionIds = Read-Host -Prompt "Enter comma-separated Subscription IDs"

# Split the subscription IDs into an array
$subscriptionIdsArray = $subscriptionIds -split ','

# Define output array
$output = @()

# Loop through each subscription ID
foreach ($subscriptionId in $subscriptionIdsArray) {
    $subscriptionId = $subscriptionId.Trim()

    # Set the current subscription
    Set-AzContext -SubscriptionId $subscriptionId

    # Check for resources and SKU information
    $resources = @(
        @{
            ResourceType = "Azure Firewall"
            Command = { Get-AzFirewall }
        },
        @{
            ResourceType = "Azure Application Gateway"
            Command = { Get-AzApplicationGateway }
        },
        @{
            ResourceType = "Azure Front Door"
            Command = { Get-AzFrontDoor }
        },
        @{
            ResourceType = "Azure Traffic Manager"
            Command = { Get-AzTrafficManagerProfile }
        },
        @{
            ResourceType = "Azure Bastion"
            Command = { Get-AzBastion }
        }
    )

    foreach ($resource in $resources) {
        try {
            # Execute the command to check for the resource
            $result = & $resource.Command

            if ($result) {
                foreach ($item in $result) {
                    $output += [PSCustomObject]@{
                        SubscriptionId = $subscriptionId
                        ResourceType   = $resource.ResourceType
                        ResourceName   = $item.Name
                        SKU            = $item.Sku.Name
                    }
                }
            } else {
                $output += [PSCustomObject]@{
                    SubscriptionId = $subscriptionId
                    ResourceType   = $resource.ResourceType
                    ResourceName   = "N/A"
                    SKU            = "not deployed"
                }
            }
        } catch {
            $output += [PSCustomObject]@{
                SubscriptionId = $subscriptionId
                ResourceType   = $resource.ResourceType
                ResourceName   = "N/A"
                SKU            = "not deployed"
            }
        }
    }
}

# Export results to CSV file
$output | Export-Csv -Path "AzureResourceCheckResults.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Results exported to AzureResourceCheckResults.csv"
