#Function VMScript-Ready
#Funtion to check Invoke-VMScript can be executed on target VM
##Version V1.0 ##
##Author: sourav.mitra1990@gmail.com##
##https://www.virtualmystery.info/post/check-a-vm-is-ready-for-invoke-vmscript##
##Date: 04/24/2021##

Function VMScript-Ready {
   Param(
            $ServerIP,
            $ServerUser,
            $ServerPass,
            $VMname,
            $Vmuser,
            $vmpass
        )
   Process {
   #Connect to target server
   $connection= Connect-VIServer -Server $ServerIP -User $ServerUser -Password $ServerPass -ErrorAction SilentlyContinue
   #Inform user if unable to connect
   if ($connection -eq $null)
      {
         Write-Host "Unable to connect to the server..."
         Write-Host "Please check the server IP and credentials!"
         Return
       }
   Else
       {
         Write-Host "Connection to target server is OK!"
       }
  #Check if the target VM is present in the server
  if(! (Get-VM -Name $VMname -ErrorAction SilentlyContinue))
    {
     Write-Host "The target VM was not found..."
     Write-Host "Please confirm name and location of the VM!"
     Return
     }
 #Confirm if the VM is running
 $vmid = Get-VM -Name $VMname
 if($vmid.PoerState -ne "PoweredON")
   {
     Write-Host "The VM is not Powered ON!"
     Write-Host "Please confirm name and location of the VM"
     Return
    }
 #Confirm VMware tools are installed and running on the target VM
 $vmid = Get-VM -Name $VMname
 if ($vmid.ExtensionData.Guest.ToolsStatus -eq "ToolsOK")
  {
  if($vmid.ExtensionData.Guest.ToolsRunningStatus -eq "guestToolsRunning")
    {Write-Host "VMware Tools Status is OK..."}
   Else
    {
     Write-Host "VNware Tools are not running"
     Return
    }
   }
   Else
   {
    Write-Host "Vmware Tools are not installed..."
    Write-Host "Please install Vmware Tools on the target VM!"
    Return
   }
 #Check script can be run on the target VM
 Try
  {
   [int]$try = 0
   $task= Invoke-VMScript -ScriptText "cd c:\" -VM $VMname `
   -GuestUser $Vmuser -GuestPassword $vmpass -ScriptType Bat -ErrorAction Stop
            }
 Catch
  {
   $try= 1
  }
 if($try -eq 0)
  {
  Write-host "Successfully completed Invoke-VMScript on $VMName running on server $ServerIP"
                
   }
 else
 {
  Write-Host "Unable to esxecute Invoke-VMScript on $VMname"
  Write-Host "Please Confirm guestOS credentials and user rights!!"
  }
  #Disconnect from server
  Disconnect-VIServer -Server $ServerIP -Confirm:$false
         
}
}
