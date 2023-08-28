using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$container_name = $Request.Query.Name

if (-not $container_name) {
    $container_name = $Request.Body.Container
}


$body = "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."

# Create Container Object

Write-Host "--------------- Creating your Director node -------------------------"

$port1 = New-AzContainerInstancePortObject -Port 8000
$port2 = New-AzContainerInstancePortObject -Port 8001

# Debug
# Write-Output $port1
# Write-Output $port2

$container = New-AzContainerInstanceObject -Name $container_name -Image nginx -Port @($port1, $port2)
New-AzContainerGroup -ResourceGroupName Federated_Learning_tutorial -Name "director-resource-creator" -Location japaneast -Container $container -OSType 'Linux' -RestartPolicy "OnFailure" -IPAddressType 'Public'

if ($container_name) {
    $body = "Hello, $container_name. This HTTP triggered function executed successfully."
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
