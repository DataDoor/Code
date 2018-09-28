<#
This Script is used to upload files ot Azure data lake:

Authenticate to Azure
Create storage
Create folder in storage is required
Upload files from local folder

#> 



<#
AUTHENTICATION FUNCTION
#>


# Prompts you for azure credentials
# Add-AzureRmAccount

## List my subscriptions
# Get-AzureRmSubscription

## Pick my Visual Studio Enterprise one
# Set-AzureRmContext -SubscriptionId '26efaaba-5054-4f31-b922-84ab9eff218e'


<#
FIND LOCATIONS AVAIABLE
#>

# Find Regions
#Register-AzureRmResourceProvider -ProviderNamespace "Microsoft.DataLakeStore"


<#
CREATE RESOURCE GROUP 
#>

# #Show current resource groups
# $rgrps = Get-AzureRmResourceGroup 

# ForEach-Object{$rgrps.rgrpname}


# # Set variables 
# $rgrpregion = "North Europe"
# $rgrpname = "Training"

# $exists = Get-AzureRmResourceGroup -Name $rgrpname -ErrorAction SilentlyContinue

# if(!$exists)
# {
#     Write-Host "Creating resource group"$rgrpname
#     New-AzureRmResourceGroup -Name $rgrpname -Location $rgrpregion
# }
# else 
# {
#     write-host $rgrpname" already exists"
# }


# <#
# CREATE DATA LAKE STORE
# #>

# # Set variables 
# $newdlname = "testing123dl"
# $rgrpname = "DatalakeTraining"
# $rgrpregion = "North Europe"

# # Does the factory exist
# $exists = Get-AzureRmDataLakeStoreAccount -ResourceGroupName $rgrpname -Name $newdlname -ErrorAction SilentlyContinue

# # Only create if does not exist
# if (! $exists)
# {
#     Write-Host "Creating azure data lake storage"
#     New-AzureRmDataLakeStoreAccount -ResourceGroupName $rgrpname -Name $newdlname -Location $rgrpregion
# }
# # Show the existing storage
# else
# {
#     Write-Host "Azure data lake storage "$newdlname" already exists"
# }



# <#
# CREATE NEW FOLDER IN DATALAKE
# #>

# $dlaccount = "datadooradls"  #This is the datalake name
# $newdlfolder = "Test" 
# $newdlfolderpath = "/"+$newdlfolder+"/"


# #Check existance for folder
# $exists = Get-AzureRmDataLakeStoreChildItem -AccountName $dlaccount -Path "/" | Where-Object {$_.name -eq $newdlfolder} -ErrorAction SilentlyContinue

# # Only create if does not exist
# if (! $exists)
# {
#     Write-Host "Creating folder named "$newdlfolder
#     New-AzureRmDataLakeStoreItem -Folder -AccountName $dlaccount -Path $newdlfolderpath |Out-Null
# }
# # Show the existing folder
# else
# {
#     Write-Host "Folder named '"$newdlfolder"' already exists"

# }



<#
UPLOAD FILES TO DATA LAKE
#>

#Set data lake variables

$filesourcepath = "\\store\"
$dlaccount = "datadooradls"
$targetfoldername  = "usage"
$dltargetfolder = "/$targetfoldername/"


$uploadfilelist = Get-ChildItem $filesourcepath -Filter *.csv 


foreach ($file in $uploadfilelist)
{

#Create source and remote path variables
$localfile = $filesourcepath+$file
$remotepath = $dltargetfolder+$file

##Import files from local to datalake
Import-AzureRmDataLakeStoreItem `
    -AccountName $dlaccount `
    -Path $localfile  `
    -Destination $remotepath `
    -ErrorAction SilentlyContinue

}



