using namespace System.Net

# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()
$timeStampSuffix = (Get-Date -Format u).Substring(0,16).Replace(" ","-").Replace(":","")

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

$storageInfo = Get-Item -path env:WEBSITE_CONTENTAZUREFILECONNECTIONSTRING

$fullConnectionString = $storageInfo.Value
$kvPairs = $fullConnectionString.Split(";")

$kvPairs
$accountName = "AccountName"
$accoountNameKeyAndValue = ($kvPairs | Where-Object { $_.Contains($substring) })
$accountNameValue = $accoountNameKeyAndValue.Split("=")[1]
$accountNameValue

$accessKey = "AccountKey"
$accessKeyKeyAndValue = ($kvPairs | Where-Object { $_.Contains($accessKey) })   
$accessKeyValue = $accessKeyKeyAndValue.Split("=")[1]
$accessKeyValue

$endpointSuffix = "EndpointSuffix"
$endpointSuffixKeyAndValue = ($kvPairs | Where-Object { $_.Contains($endpointSuffix) })
$endpointSuffixValue = $endpointSuffixKeyAndValue.Split("=")[1]
$endpointSuffixValue

$storageEndpoint = "https://$accountNameValue.$endpointSuffixValue"
$storageEndpoint



# Get the custom roles at the tenant root scope
$customRoles = Get-AzRoleDefinition -Scope '/' | Where-Object {$_.IsCustom -eq 'True'} | Select-Object -Property Name

$outputBlob = "outputBlob-$timeStampSuffix.csv"

$customRoles | Export-Csv -path ./$outputBlob -NoTypeInformation -Force

Import-Csv -path ./$outputBlob -Verbose

$destContext = New-AzStorageContext -StorageAccountName $accountNameValue -StorageAccountKey $accessKeyValue
$containerName = "operation-logs"

# Copy the blob
Start-AzStorageBlobCopy -SrcFile ./$outputBlob -Context $sourceContext -DestContainer $containerName -DestContext $destContext