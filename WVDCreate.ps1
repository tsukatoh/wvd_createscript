<#
###########################################
# Windows Virtual Desktop creation script #
###########################################

# Create a password file in advance with the following command.
  $tmpCred = Get-Credential
  $tmpCred.Password | ConvertFrom-SecureString | Set-Content "pwd.dat"

# Outline of processing
  1. Create ResouceGroup
  2. Create WVD HostPool
  3. Create WVD Application Group
  4. Create WVD WorkSpace
  5. Add Application Group to Work WorkSpace
  6. Grant permissions to Security Group.
  7. Add virtual machine to a host pool => Conducted from azure portal
#>
$LogFileName = (Get-Date -format "yyyyMMddHHmm") + ".txt"

# Import module
import-module Az
import-module AzureAD

# Set Parameters
$RGName = "wvd-rg"                      # Resouce Group Name
$RGLocation = "japaneast"               # Resouce Group Location
$HPName = "HostPoolName"                # Host Pool Name
$HPDescription = "Description"          # Host Pool Description
$HPFriendlyName = "FriendlyName"        # Host Pool Friendly Name
$MaxSessionLimit = "5"                  # Max Session Limit
$APName = "ApplicationGRName"           # Application Group Name
$APDescription = "Description"          # Application Group Description
$APFriendlyName = "FriendlyName"        # Application Group Friendly Name
$WSName = "WorkspaceName"               # WorkSpace Name
$WSDescription = "Description"          # WorkSpace Description
$WSFriendlyName = "FriendlyName"        # WorkSpace Friendly Name
$WVDLocation = "eastus"                 # WVD Location
$ConnectUser = "admin@domain.com"       # Azure and AzureAD resource creation account
$WVDGroupName = "WVDUsers"              # WVD usage group

# Create credential
$password = Get-Content "pwd.dat" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential $ConnectUser, $password

# Connect Azure
Connect-AzAccount -Credential $credential

# Connect AzureAD
Connect-AzureAD -Credential $credential

# Create ResouceGroup
If(!(Get-AzResourceGroup -Name $RGName)){
    New-AzResourceGroup -Name $RGName -Location $RGLocation
} Else {
    $msg = "Did not create the Resouce Group [" + $RGName + "] because it already exists."
    Write-Output $msg | Out-File -FilePath $LogFileName -Encoding Default -append 
}

# Create WVD HostPool
if(!(Get-AzWvdHostPool -Name $HPName -ResourceGroupName $RGName)) {
    New-AzWvdHostPool -ResourceGroupName $RGName `
                                -Name $HPName `
                                -Location $WVDLocation `
                                -PreferredAppGroupType 'Desktop' `
                                -HostPoolType 'Pooled' `
                                -LoadBalancerType 'DepthFirst' `
                                -RegistrationTokenOperation 'Update' `
                                -ExpirationTime $((get-date).ToUniversalTime().AddDays(1).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ')) `
                                -Description $HPDescription `
                                -FriendlyName $HPFriendlyName `
                                -MaxSessionLimit $MaxSessionLimit `
                                -VMTemplate $null `
                                -CustomRdpProperty $null `
                                -Ring $null `
                                -ValidationEnvironment:$false
} Else {
    $msg = "Did not create the Host Pool [" + $HPName + "] because it already exists."
    Write-Output $msg | Out-File -FilePath $LogFileName -Encoding Default -append 
}

# Get WVD HostPool ID
$HPPath = Get-AzWvdHostPool -Name $HPName -ResourceGroupName $RGName

# Create WVD Application Group
if(!(Get-AzWvdApplicationGroup -Name $APName -ResourceGroupName $RGName)) {
    New-AzWvdApplicationGroup -ResourceGroupName $RGName `
                            -Name $APName `
                            -Location $WVDLocation `
                            -FriendlyName $APFriendlyName `
                            -Description $APDescription `
                            -HostPoolArmPath $HPPath.Id `
                            -ApplicationGroupType 'Desktop'
} Else {
    $msg = "Did not create the Application Group [" + $APName + "] because it already exists."
    Write-Output $msg | Out-File -FilePath $LogFileName -Encoding Default -append 
}

# Get WVD Application Group ID
$APPath = Get-AzWvdApplicationGroup -Name $APName -ResourceGroupName $RGName

# Create WVD WorkSpace
If(!(Get-AzWvdWorkspace -Name $WSName -ResourceGroupName $RGName)) {
    New-AzWvdWorkspace -ResourceGroupName $RGName `
                        -Name $WSName `
                        -Location $WVDLocation `
                        -FriendlyName $WSFriendlyName `
                        -ApplicationGroupReference $null `
                        -Description $WSDescription
} Else {
    $msg = "Did not create the WorkSpace [" + $WSName + "] because it already exists."
    Write-Output $msg | Out-File -FilePath $LogFileName -Encoding Default -append 
}


# Add WVD Application Group to WorkSpace
Register-AzWvdApplicationGroup -ResourceGroupName $RGName `
                                    -WorkspaceName $WSName `
                                    -ApplicationGroupPath $APPath.Id

# Grant permissions to WVD
$WVDUsersGroup = Get-AzureADGroup -SearchString $WVDGroupName
If($WVDUsersGroup) {
    New-AzRoleAssignment -ObjectId $WVDUsersGroup.ObjectID -RoleDefinitionName "Desktop Virtualization User" -ResourceName $APName -ResourceGroupName $RGName -ResourceType 'Microsoft.DesktopVirtualization/applicationGroups'
} Else {
    $msg = "Did not process because the group [" + $WVDGroupName + "] did not exist."
    Write-Output $msg | Out-File -FilePath $LogFileName -Encoding Default -append 
}

# Add Windows 10 image to WVD Host Pool
$msg = "Please add virtual machine to a host pool from Azure portal."
Write-Host $msg -BackgroundColor Green -ForegroundColor Black
Write-Output $msg | Out-File -FilePath $LogFileName -Encoding Default -append 
