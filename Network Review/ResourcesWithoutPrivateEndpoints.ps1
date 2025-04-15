# Prompt user for subscription IDs
$subscriptionInput = Read-Host "Enter subscription IDs (comma-separated)"
$subscriptions = $subscriptionInput -split "," | ForEach-Object { $_.Trim() }

# List of resource types to check
$resourceTypesSupportingPrivateEndpoints = @(
    "Microsoft.ApiManagement/service",
    "Microsoft.App/ManagedEnvironments",
    "Microsoft.Appconfiguration/configurationStores",
    "Microsoft.Attestation/attestationProviders",
    "Microsoft.Automation/automationAccounts",
    "Microsoft.AzureCosmosDB/databaseAccounts",
    "Microsoft.Batch/batchAccounts",
    "Microsoft.Cache/Redis",
    "Microsoft.Cache/redisEnterprise",
    "Microsoft.CognitiveServices/accounts",
    "Microsoft.Compute/diskAccesses",
    "Microsoft.ContainerRegistry/registries",
    "Microsoft.ContainerService/managedClusters",
    "Microsoft.Databricks/workspaces",
    "Microsoft.DataFactory/factories",
    "Microsoft.DBforMariaDB/servers",
    "Microsoft.DBforMySQL/flexibleServers",
    "Microsoft.DBforMySQL/servers",
    "Microsoft.DBforPostgreSQL/flexibleServers",
    "Microsoft.DBforPostgreSQL/serverGroupsv2",
    "Microsoft.DBforPostgreSQL/servers",
    "Microsoft.DesktopVirtualization/hostpools",
    "Microsoft.DesktopVirtualization/workspaces",
    "Microsoft.Devices/IotHubs",
    "Microsoft.Devices/provisioningServices",
    "Microsoft.DeviceUpdate/accounts",
    "Microsoft.DigitalTwins/digitalTwinsInstances",
    "Microsoft.DocumentDb/mongoClusters",
    "Microsoft.EventGrid/domains",
    "Microsoft.EventGrid/topics",
    "Microsoft.EventHub/namespaces",
    "Microsoft.HDInsight/clusters",
    "Microsoft.HealthcareApis/services",
    "Microsoft.Insights/privatelinkscopes",
    "Microsoft.IoTCentral/IoTApps",
    "Microsoft.Keyvault/managedHSMs",
    "Microsoft.KeyVault/vaults",
    "Microsoft.Kusto/clusters",
    "Microsoft.Logic/integrationAccounts",
    "Microsoft.MachineLearningServices/registries",
    "Microsoft.MachineLearningServices/workspaces",
    "Microsoft.Media/mediaservices",
    "Microsoft.Migrate/assessmentProjects",
    "Microsoft.Network/applicationgateways",
    "Microsoft.Network/privateLinkServices",
    "Microsoft.PowerBI/privateLinkServicesForPowerBI",
    "Microsoft.Purview/accounts",
    "Microsoft.RecoveryServices/vaults",
    "Microsoft.Relay/namespaces",
    "Microsoft.Search/searchServices",
    "Microsoft.ServiceBus/namespaces",
    "Microsoft.SignalRService/SignalR",
    "Microsoft.SignalRService/webPubSub",
    "Microsoft.Sql/managedInstances",
    "Microsoft.Sql/servers",
    "Microsoft.Storage/storageAccounts",
    "Microsoft.StorageSync/storageSyncServices",
    "Microsoft.Synapse/privateLinkHubs",
    "Microsoft.Synapse/workspaces",
    "Microsoft.Web/hostingEnvironments",
    "Microsoft.Web/sites",
    "Microsoft.Web/staticSites"
)

# Function to check for Private Endpoints
function HasPrivateEndpoint($resourceId) {
    try {
        $privateEndpoints = Get-AzPrivateEndpointConnection -ResourceId $resourceId
        return $privateEndpoints.Count -gt 0
    } catch {
        # Return false if ResourceId is not valid for private endpoints
        return $false
    }
}

# Initialize an array to store the results
$results = @()

# Loop through each subscription
foreach ($subscriptionId in $subscriptions) {
    # Set the current subscription context
    Set-AzContext -SubscriptionId $subscriptionId

    # Get all resources in the subscription
    $resources = Get-AzResource

    # Loop through resources to check resource type and private endpoint association
    foreach ($resource in $resources) {
        if ($resourceTypesSupportingPrivateEndpoints -contains $resource.ResourceType -and -not (HasPrivateEndpoint $resource.ResourceId)) {
            $results += [PSCustomObject]@{
                SubscriptionId = $subscriptionId
                ResourceName   = $resource.Name
                ResourceType   = $resource.ResourceType
                ResourceId     = $resource.ResourceId
            }
        }
    }
}

# Export the results to a CSV file
$outputCsv = "ResourcesWithoutPrivateEndpoints.csv"
$results | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Output "Report generated: $outputCsv"
