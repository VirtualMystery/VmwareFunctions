#
#Function to install ESXi VIBs using PowerCLI
#Written by sourav.mitra1990@gmail.com
#For more details: https://www.virtualmystery.info/post/powercli-function-to-install-vibs##
#www.virtualmystery.info
#

#Function to upload vib to datastore from local path and install to the selected server
function Install-HostVib{
    #Define all parameters required
    Param (
            [Parameter(Mandatory=$true)][string][ValidateNotNullorEmpty()]$VibName,
            [Parameter(Mandatory=$true)][string][ValidateNotNullorEmpty()]$LocalVibPath,
            [Parameter(Mandatory=$true)][string][ValidateNotNullorEmpty()]$VIBDatastore,
            [Parameter(Mandatory=$true)][string][ValidateNotNullorEmpty()]$Server,
            [Parameter(Mandatory=$true)][string][ValidateNotNullorEmpty()]$RootUser,
            [Parameter(Mandatory=$true)][string][ValidateNotNullorEmpty()]$RootPassword
            )
        #Connect to the server
        Connect-VIServer -Server $Server -User $RootUser -Password $RootPassword

        #Declare VIB paths
        $vibdspath = "DS:\VIB\$VibName"
        $VibUrl= "[$VIBDatastore]VIB/$VibName"

        #upload the VIB to target datastore
        $ds= Get-Datastore $VIBDatastore
        New-PSDrive -Location $ds -Name DS -PSProvider VimDatastore -Root "\" > $null
        Copy-DatastoreItem -Item $LocalVibPath -Destination $vibdspath -ErrorAction SilentlyContinue -Force -Recurse
        Remove-PSDrive -Name DS 

        #Install the VIB to the server
        $vmhost= Get-VMHost -Name $Server
        $esxcli= Get-EsxCli -VMHost $vmhost -V2
                $vibParm = @{
                                viburl = $VibUrl
                                dryrun = $false
                                nosigcheck = $true
                                maintenancemode= $false
                                force = $false
                            }
        $vibinstall= $ESXCLI.software.vib.install.Invoke($vibParm)

        #Return message to user if vib installation was successful         
        Write-Host "$vibinstall.Message" -BackgroundColor DarkYellow
        
Disconnect-VIServer * -Confirm:$false
}
