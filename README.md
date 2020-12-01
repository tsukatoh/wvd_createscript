# Windows Virtual Desktop creation script
## Introduction
This script creates a Windows virtual desktop resource.
To connect the virtual machine image to the Host Pool, you need to work from the Azure portal.
In addition, it is assumed that the environment for Azure AD Domain Services or Hybrid AD join has already been created.

## Operating environment
Please install the following command in Powershell in advance by "Run as administrator".
```
Install-Module -Name Az -AllowClobber
Install-Module -Name AzureAD
```

## Create a password file in advance with the following command.
In the same directory as the script, run the following to create credentials for users with Azure and Azure AD administrative privileges.
```
$tmpCred = Get-Credential
$tmpCred.Password | ConvertFrom-SecureString | Set-Content "pwd.dat"
```

## Script processing overview.
The process executed by the PowerShell script is as follows.
  1. Create ResouceGroup
  2. Create WVD HostPool
  3. Create WVD Application Group
  4. Create WVD WorkSpace
  5. Add Application Group to Work WorkSpace
  6. Grant permissions to Security Group.

## Variables required for script.
Set a Resouce Group name.
```
$RGName = "{ResouceGroup name}"
```

Set a Resouce Group location.
```
$RGLocation = "{ResouceGroup location}"
```

Set a WVD Host Pool name.
```
$HPName = "{HostPool name}"
```

Set a WVD Host Pool description.
```
$HPDescription = "{Description}"
```

Set a WVD Host Pool friendly name.
```
$HPFriendlyName = "{FriendlyName}"
```

Set a WVD max session limit.
```
$MaxSessionLimit = "5"
```

Set a WVD Application Group name.
```
$APName = "{ApplicationGroup name}"
```

Set a WVD Application Group Description.
```
$APDescription = "{Description}"
```

Set a WVD Application Group Friendly Name.
```
$APFriendlyName = "{Friendly name}"
```

Set a WVD WorkSpace name.
```
$WSName = "{Workspace name}"
```

Set a WVD WorkSpace Description.
```
$WSDescription = "{Description}"
```

Set a WVD WorkSpace Friendly name.
```
$WSFriendlyName = "{Friendly name}"
```

Set a WVD location.
```
$WVDLocation = "eastus"
```

Set a resouce creation account.
```
$ConnectUser = "admin@domain.com"
```

Set a WVD usage security group name.
```
$WVDGroupName = "WVDUsers"
```

## Add virtual machine to a host pool => Conducted from azure portal
1. Open the Host Pool you created from the Azure portal.
![WVD host pool 1](https://cdn-ak.f.st-hatena.com/images/fotolife/t/tsukatoh/20201201/20201201183639.png)

2. Continue with the settings as they are.
![WVD host pool 2](https://cdn-ak.f.st-hatena.com/images/fotolife/t/tsukatoh/20201201/20201201183652.png)

3. The Virtual machine location should be in the same region as the created virtual network. Image can be a pre-created image or a Marcketplace image. Select a virtual network and subnet. Enter the domain administrator account to join the domain.
![WVD host pool 3](https://cdn-ak.f.st-hatena.com/images/fotolife/t/tsukatoh/20201201/20201201183702.png)

4. Click Create.
![WVD host pool 4](https://cdn-ak.f.st-hatena.com/images/fotolife/t/tsukatoh/20201201/20201201183715.png)

5. Once the desktop is created, connect from the RD Client and verify.
![WVD host pool 5](https://cdn-ak.f.st-hatena.com/images/fotolife/t/tsukatoh/20201201/20201201183726.png)


## reference
[Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/virtual-desktop/expand-existing-host-pool#add-virtual-machines-with-the-azure-portal?WT.mc_id=AZ-MVP-5002464)