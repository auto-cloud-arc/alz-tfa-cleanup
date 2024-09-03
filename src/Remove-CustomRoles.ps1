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

# Example of retrieving an environment variable
$storageInfo = Get-Item -path env:WEBSITE_CONTENTAZUREFILECONNECTIONSTRING

# Get the custom roles at the tenant root scope
$customRolesToRemove = Get-AzRoleDefinition -Scope '/' | Where-Object {($_.IsCustom -eq 'True') -and ($_.Name -match '^Azure Landing Zones')} | Select-Object -Property Name

$mgScopes = (Get-AzManagementGroup).id 
$subScopePrefix = "/subscriptions/"
$subScopes = (Get-AzSubscription).id
# One-shot: Append $subScopePrefix to each subscription ID
$subScopes = $subScopes | ForEach-Object { $subScopePrefix + $_ }
# Two-shot: Append $mgScopes to $subScopes
$scopes = $mgScopes + $subScopes
$resultSet = @()
$i = 0
Write-Host "REMOVE CUSTOM ROLES FROM TENANT ROOT AND BELOW: $timeStampSuffix UTC"
foreach ($scope in $scopes) {
    # Your code here to process each scope  
    Write-Host "Processing scope: $scope"
    foreach ($role in $customRolesToRemove.Name) {
        $roleAssignments =  Get-AzRoleAssignment | where-object {$_.RoleDefinitionName -match "^Azure Landing Zones"}
        foreach ($assignment in $roleAssignments) {
            # Remove-AzRoleAssignment -ObjectId $assignment.ObjectId -RoleDefinitionName $role -Scope $scope -Verbose
            $i++
            Write-Host "Index: $i    Performing the what-if operation: Remove role assignment for role: $role from object: $($assignment.ObjectId)"
            $resultSet += "Index: $i    Performing the what-if operation: Remove role assignment for role: $role from object: $($assignment.ObjectId)"
        }
    }
}

# build results path
$logPath = '../results'
$resultFile = "result-$timeStampSuffix.log"

if (-not(Test-Path -Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath -Verbose
}

$resultsPath = Join-Path -Path $logPath -ChildPath $resultFile -Verbose
Set-Content -Path $resultsPath -Value $resultSet

Write-Host "Confirm that export works..."
Get-Content -Path $resultsPath -Verbose