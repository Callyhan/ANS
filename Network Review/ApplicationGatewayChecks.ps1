# Login to Azure
Connect-AzAccount

# Prompt the user to enter subscription IDs (comma-delimited)
$subscriptionIds = Read-Host -Prompt "Enter subscription IDs (comma-delimited)"
$subscriptions = $subscriptionIds -split ','

# Create an array to hold the results
$results = @()

foreach ($subscription in $subscriptions) {
    # Set the context to the subscription
    Set-AzContext -SubscriptionId $subscription.Trim()

    # Get all Application Gateways in the subscription
    $appGateways = Get-AzApplicationGateway

    foreach ($appGateway in $appGateways) {
        # Initialize variables for outputs
        $backendHealthStatus = ""
        $diagnosticSettings = ""
        $autoscaling = "N/A"
        $zoneRedundancy = "N/A"

        # Get backend health status
        try {
            $healthProbes = Get-AzApplicationGatewayBackendHealth -ApplicationGateway $appGateway
            if ($healthProbes.BackendAddressPools) {
                foreach ($pool in $healthProbes.BackendAddressPools) {
                    foreach ($entry in $pool.BackendHttpSettingsCollection) {
                        $statuses = $entry.BackendServerHealthCollection | Where-Object { $_.Status -ne "Healthy" }
                        if ($statuses) {
                            $backendHealthStatus = $statuses.Status -join "; "
                        }
                    }
                }
            } else {
                $backendHealthStatus = "no probes configured"
            }
        } catch {
            $backendHealthStatus = "no probes configured"
        }

        # Get diagnostic settings
        $diagSettings = Get-AzDiagnosticSetting -ResourceId $appGateway.Id
        if ($diagSettings.Count -gt 0) {
            $diagnosticSettings = $diagSettings.Name -join ", "
        } else {
            $diagnosticSettings = "no diagnostic settings configured"
        }

        # Check for autoscaling
        if ($appGateway.Sku.Capacity -eq $null) {
            $autoscaling = $appGateway.AutoscaleConfiguration.MinCapacity + "-" + $appGateway.AutoscaleConfiguration.MaxCapacity
        }

        # Check for zone redundancy
        if ($appGateway.Zone -ne $null) {
            $zoneRedundancy = $appGateway.Zone -join ", "
        }

        # Add details to the results array
        $results += [PSCustomObject]@{
            SubscriptionId         = $subscription.Trim()
            ApplicationGatewayName = $appGateway.Name
            ResourceGroup          = $appGateway.ResourceGroupName
            BackendHealthStatus    = $backendHealthStatus
            TLSConfig              = $appGateway.SslPolicy.PolicyType
            DiagnosticSettings     = $diagnosticSettings
            SKU                    = $appGateway.Sku.Name
            Autoscaling            = $autoscaling
            ZoneRedundancy         = $zoneRedundancy
        }
    }
}

# Export results to a CSV file
$results | Export-Csv -Path "ApplicationGatewayDetails.csv" -NoTypeInformation

Write-Host "Results exported to 'ApplicationGatewayDetails.csv'."
