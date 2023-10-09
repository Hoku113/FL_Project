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
New-AzContainerGroup -ResourceGroupName $env:ACI_RESOURCE_GOURP_NAME -Name $env:DIRECTOR_GROUP -Location japaneast `
-Container $container -Image "mcr.microsoft.com/azure-cli" -OSType 'Linux' -RestartPolicy "OnFailure" -IPAddressType 'Public' `
# -Command "/bin/bash -c "" cd && az login --service-principal --username $env:AZURE_USER --password $env:AZURE_PASSWORD --teanant $env:AZURE_TENANT && sudo apt update && pip install -U pip && pip install openfl `
# && git clone https://github.com/hiouchiy/Federated_Learning_First_Step_Tutorial.git && cd Federated_Learning_First_Step_Tutorial/director && sed -i -e '3 s/localhost/$privateIP/g' director_config.yaml && fx director start --disable-tls -c director_config.yaml
# """

if ($container_name) {
    $body = "Success! $container_name is created!"
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
