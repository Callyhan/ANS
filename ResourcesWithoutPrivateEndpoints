# PowerShell script to report whether Private Endpoints have been deployed to all resources within a subscription in Azure

# Login to Azure
Connect-AzAccount

# Get all resources in the subscription
$resources = Get-AzResource

# Initialize an array to store resources without Private Endpoints
$resourcesWithoutPrivateEndpoint = @()

# Loop through each resource to check for Private Endpoints
foreach ($resource in $resources) {
    $privateEndpoints = Get-AzPrivateEndpoint -ResourceGroupName $resource.ResourceGroupName -ResourceName $resource.Name -ErrorAction SilentlyContinue
    if (-not $privateEndpoints) {
        $resourcesWithoutPrivateEndpoint += [PSCustomObject]@{
            ResourceName = $resource.Name
            ResourceType = $resource.ResourceType
            ResourceGroup = $resource.ResourceGroupName
        }
    }
}

# Report the results
if ($resourcesWithoutPrivateEndpoint.Count -eq 0) {
    Write-Output "All resources have Private Endpoints deployed."
} else {
    Write-Output "The following resources do not have Private Endpoints deployed:"
    $resourcesWithoutPrivateEndpoint | ForEach-Object {
        Write-Output "Resource Name: $($_.ResourceName), Resource Type: $($_.ResourceType), Resource Group: $($_.ResourceGroup)"
    }

    # Output the results to a CSV file
    $resourcesWithoutPrivateEndpoint | Export-Csv -Path "ResourcesWithoutPrivateEndpoints.csv" -NoTypeInformation
    Write-Output "Results have been exported to ResourcesWithoutPrivateEndpoints.csv"
}
