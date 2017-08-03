# ------------------------------------------------------------
# 2017 - Microsoft Managed Services 
# Monitoring Platform
# ------------------------------------------------------------ 

# Default Values
$subscriptionId = Get-AutomationVariable -Name 'SubPROD'
$resourceGroupName = Get-AutomationVariable -Name 'EnvPROD'
$workspaceId = Get-AutomationVariable -Name 'MonPROD'
$connectionName = "AzureRunAsConnection"

# Get the connection "AzureRunAsConnection "
try
{
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    Write-Output "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}


# Select the right Azure Subscription and resource group
Try 
{
    Select-AzureRmSubscription -SubscriptionId $subscriptionId
    $resources = Find-AzureRmResource -ResourceGroupNameEquals $resourceGroupName
} 
Catch 
{
    Write-Error -Message $_.Exception
    throw $_.Exception    
}

foreach ($resource in $resources)
{
    Write-Output "Enable monitoring for Resource"
    Write-Output ("Name   : {0}" -f $resource.ResourceName)
    Write-Output ("Type   : {0}" -f $resource.ResourceType)
    
    Try
    {
        Set-AzureRmDiagnosticSetting -ResourceId $resource.ResourceId  -WorkspaceId $workspaceId -Enabled $true -ErrorAction Stop
        Write-Output ("Result : Successfully connected")
    } 
    Catch
    {
        Write-Output ("Result : {0}" -f $_.Exception.Message)
    }
        
    Write-Output ""
}

