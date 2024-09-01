using namespace System.Net

# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

# Get the custom roles at the tenant root scope
$customRoles = Get-AzRoleDefinition -Scope '/' | Where-Object {$_.IsCustom -eq 'True'} | Select-Object -Property Name

$customRoles | Export-Csv -path ./customRoles.csv -NoTypeInformation -Force

# Copy the custom roles to the storage account output binding
Out-File -FilePath $outputBlob -InputObject $customRoles -Force
