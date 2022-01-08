##Function to set HA configuration parameters
##Written by: sourav.mitra1990@gmail.com
##For more infomration: https://www.virtualmystery.info/post/powercli-function-to-configure-ha-parameters#
##This function assumes user is connected to a vcenter instance
##Target hosts are in a cluster setup with HA enabled
#Begin function
function ConfigureHA-Param{
#Define all configuration parameters
Param (
[Parameter(Mandatory=$true)][string][ValidateNotNullorEmpty()]$cluster,
[Parameter(Mandatory=$true)][string][ValidateSet("disabled", "lowest", "low", "medium", "high", "highest")]$HostFailureResponse,
[Parameter(Mandatory=$true)][string][ValidateSet("none", "powerOff", "shutdown")]$HostIsolationResponse,
[Parameter(Mandatory=$true)][string][ValidateSet("disabled", "warning", "restartAggressive")]$PDL,
[Parameter(Mandatory=$true)][string][ValidateSet("disabled", "warning", "restartConservative", "restartAggressive")]$APD,
[Parameter(Mandatory=$true)][string][ValidateSet("vmMonitoringDisabled", "vmMonitoringOnly", "vmAndAppMonitoring")]$VMMonitoring,
[Parameter(Mandatory=$true)][string][ValidateSet("allFeasibleDs", "userSelectedDs", "allFeasibleDsWithUserPreference")]$HBDatastore,
[Parameter(Mandatory=$true)][int][ValidateNotNullorEmpty()]$FailoverLevel
)
#Function execution starts
$clusterID= Get-Cluster -Name "$cluster" 

#Set the parameters
$spec = New-Object VMware.Vim.ClusterConfigSpecEx
$spec.Orchestration = New-Object VMware.Vim.ClusterOrchestrationInfo
$spec.Orchestration.DefaultVmReadiness = New-Object VMware.Vim.ClusterVmReadiness
$spec.Orchestration.DefaultVmReadiness.ReadyCondition = 'none'
$spec.Orchestration.DefaultVmReadiness.PostReadyDelay = 0
$spec.DrsConfig = New-Object VMware.Vim.ClusterDrsConfigInfo
$spec.DasConfig = New-Object VMware.Vim.ClusterDasConfigInfo
$spec.DasConfig.AdmissionControlEnabled = $true
$spec.DasConfig.DefaultVmSettings = New-Object VMware.Vim.ClusterDasVmSettings
$spec.DasConfig.DefaultVmSettings.RestartPriority = "$HostFailureResponse"
$spec.DasConfig.DefaultVmSettings.VmComponentProtectionSettings = New-Object VMware.Vim.ClusterVmComponentProtectionSettings
$spec.DasConfig.DefaultVmSettings.VmComponentProtectionSettings.VmStorageProtectionForPDL = "$PDL"
$spec.DasConfig.DefaultVmSettings.VmComponentProtectionSettings.VmReactionOnAPDCleared = 'none'
$spec.DasConfig.DefaultVmSettings.VmComponentProtectionSettings.VmStorageProtectionForAPD = "$APD"
$spec.DasConfig.DefaultVmSettings.IsolationResponse = "$HostIsolationResponse"
$spec.DasConfig.DefaultVmSettings.VmToolsMonitoringSettings = New-Object VMware.Vim.ClusterVmToolsMonitoringSettings
$spec.DasConfig.VmMonitoring = "$VMMonitoring"
$spec.DasConfig.HeartbeatDatastore = New-Object VMware.Vim.ManagedObjectReference[] (0)
$spec.DasConfig.HBDatastoreCandidatePolicy = "$HBDatastore"
$spec.DasConfig.AdmissionControlPolicy = New-Object VMware.Vim.ClusterFailoverResourcesAdmissionControlPolicy
$spec.DasConfig.AdmissionControlPolicy.FailoverLevel = $FailoverLevel
$spec.DasConfig.AdmissionControlPolicy.AutoComputePercentages = $true
$spec.DasConfig.AdmissionControlPolicy.PMemAdmissionControlEnabled = $false
$spec.DasConfig.VmComponentProtecting = 'enabled'
$spec.DasConfig.Enabled = $true
$spec.DasConfig.HostMonitoring = 'enabled'
$spec.DpmConfig = New-Object VMware.Vim.ClusterDpmConfigInfo
$modify = $true
$_this = Get-View -Id $clusterID.ExtensionData.MoRef
$_this.ReconfigureComputeResource_Task($spec, $modify)
##End of Function
}
