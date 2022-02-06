#Function to enable and configure DRS in a cluster
#Written by sourav.mitra1990@gmail.com
#For more details: https://www.virtualmystery.info/post/##
#CreatedOn: 06/02/2022
#www.virtualmystery.info

#Function to enable DRS and set DRS configurations
function Set-DRS{

    #Define DRS configuration parameters
        Param (
        [Parameter(Mandatory=$true)][string][ValidateNotNullorEmpty()]$cluster,
        [Parameter(Mandatory=$false)][bool][ValidateNotNullorEmpty()]$DRSEnabled,
        [Parameter(Mandatory=$true)][bool][ValidateNotNullorEmpty()]$ScalableShares,
        [Parameter(Mandatory=$false)][int][ValidateSet(1, 2, 3, 4, 5)]$DRSAgressionLevel,
        [Parameter(Mandatory=$false)][string][ValidateSet("manual", "partiallyAutomated", "fullyAutomated")]$DRSAutomationLevel,
        [Parameter(Mandatory=$true)][bool][ValidateNotNullorEmpty()]$BalanceVmsPerHost,
        [Parameter(Mandatory=$false)][int][ValidateNotNullorEmpty()]$MaxVcpusPerCore,
        [Parameter(Mandatory=$true)][bool][ValidateNotNullorEmpty()]$ProactiveDRS,
        [Parameter(Mandatory=$true)][bool][ValidateNotNullorEmpty()]$DPMEnabled,
        [Parameter(Mandatory=$false)][int][ValidateSet(1, 2, 3, 4, 5)]$DPMAgressionLevel,
        [Parameter(Mandatory=$false)][string][ValidateSet("manual", "automated")]$DPMAutomationLevel
        )

       #Begin DRS configurations

       #Set DRS, automation level and aggression level
            $spec = New-Object VMware.Vim.ClusterConfigSpecEx
            $spec.DrsConfig = New-Object VMware.Vim.ClusterDrsConfigInfo
            $spec.DrsConfig.DefaultVmBehavior = "$DRSAutomationLevel"
            [int]$drscalc= 6 - $DRSAgressionLevel
            $spec.DrsConfig.VmotionRate = $drscalc
            $spec.DrsConfig.Enabled = $DRSEnabled
            $spec.DrsConfig.EnableVmBehaviorOverrides = $true
       #Set scalable shares
            if ($ScalableShares -eq $true){
            $spec.DrsConfig.ScaleDescendantsShares = 'scaleCpuAndMemoryShares'}
            else {
            $spec.DrsConfig.ScaleDescendantsShares = 'disabled'}

        #Set VMs host balance configrations
            $spec.DrsConfig.Option = New-Object VMware.Vim.OptionValue[] (2)
            $spec.DrsConfig.Option[0] = New-Object VMware.Vim.OptionValue
            if ($BalanceVmsPerHost -eq $true){
            $spec.DrsConfig.Option[0].Value = '1'}
            $spec.DrsConfig.Option[0].Key = 'TryBalanceVmsPerHost'
        #Set maxCPU configuration
            $spec.DrsConfig.Option[1] = New-Object VMware.Vim.OptionValue
            $spec.DrsConfig.Option[1].Key = 'MaxVcpusPerCore'
            if($MaxVcpusPerCore -gt 0){
            $spec.DrsConfig.Option[1].Value = "$MaxVcpusPerCore"}
        #Set Proactive DRS patameters
            $spec.ProactiveDrsConfig = New-Object VMware.Vim.ClusterProactiveDrsConfigInfo
            $spec.ProactiveDrsConfig.Enabled = $DPMEnabled
        #Set DPM configuration
            $spec.DpmConfig = New-Object VMware.Vim.ClusterDpmConfigInfo
            [int]$dpmcalc= 6 - $DPMAgressionLevel
            if ($DPMEnabled){
            $spec.DpmConfig.HostPowerActionRate = $dpmcalc}
            else{
            $spec.DpmConfig.HostPowerActionRate = 3} 

            $spec.DpmConfig.Enabled = $DPMEnabled
            if ($DPMEnabled -eq $true)
            {
            $spec.DpmConfig.DefaultDpmBehavior = "$DPMAutomationLevel"
            }

        #Set the DRS configratios to the cluster
            $modify = $true
            $cluster_ID= Get-Cluster -Name "$cluster"
            $_this = Get-View -Id $cluster_ID.Id
            $_this.ReconfigureComputeResource_Task($spec, $modify)
}
