#Log into Azure
Connect-AzAccount

#Select the correct subscription
Get-AzSubscription -SubscriptionName "SUBNAME" | Select-AzSubscription

#Create a resource groups
$rgMonitoring="rg-monitoring-poc"
$rgBds="rg-bds-poc"
$rgVms="rg-vms-poc"
$rgAks="rg-aks-poc"
$rgMsftAks="rg-msft-aks-poc"
$rgServices="rg-services-poc"
$rgNetwork="rg-network-poc"

$location='westus2'

#Tags
$tags = @{
    "AMBIENTE"="";
    "ANOCRIACAO"="";
    "APLICACAO"="";
    "EMPRESA"=""
 }

#Name of resources
$pipElbVms="pip-elb-vms-poc"
$elbVms="elb-vms-poc"
$feElbVms="fe-01-elb-vms-poc"
$bePollElbVMs="bep-vms-poc"

$logAnalyticsName="la-wks-poc"

$vnetPocName="vnet-poc"
$subnetVmsName="subnet-vms-poc"
$subnetPeName="subnet-pe-poc"
$subnetAksName="subnet-aks-poc"
$subnetCassandraName="subnet-ami-cassandra-poc"

$vnetPrefix="10.0.0.0/8"
$subnetVmsPrefix="10.0.0.0/24"
$subnetPePrefix="10.0.1.0/27"
$subnetAksPrefix="10.0.1.32/27"
$subnetCassandraPrefix="10.0.1.64/27"

$nsgSubnetVmsName="nsg-$subnetVmsName-$vnetPocName"

$vm1Name="injetor-01-poc"
$vm1Size="Standard_B2ms"

$aksName="aks-poc"
$nodSize="Standard_D2_v2"

#Create Resource Groups
New-AzResourceGroup -Name $rgMonitoring -Location $location -Tag $tags
New-AzResourceGroup -Name $rgBds -Location $location -Tag $tags
New-AzResourceGroup -Name $rgVms -Location $location -Tag $tags
New-AzResourceGroup -Name $rgAks -Location $location -Tag $tags
New-AzResourceGroup -Name $rgServices -Location $location -Tag $tags
New-AzResourceGroup -Name $rgNetwork -Location $location -Tag $tags

#Create a network security group and rules
$nsgRule1 = New-AzNetworkSecurityRuleConfig -Name "allowSsh-$subnetVmsName" -Description 'Allow SSH' `
  -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
  -SourceAddressPrefix Internet -SourcePortRange * `
  -DestinationAddressPrefix * -DestinationPortRange 22

$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $rgNetwork `
  -Location $location `
  -Name $nsgSubnetVmsName `
  -SecurityRules $nsgRule1 `
  -Tag $tags

#Create a virtual network and subnets config
$subnetConfigVms = New-AzVirtualNetworkSubnetConfig -Name $subnetVmsName -AddressPrefix $subnetVmsPrefix
$subnetConfigPe = New-AzVirtualNetworkSubnetConfig -Name $subnetPeName -AddressPrefix $subnetPePrefix
$subnetConfigAks = New-AzVirtualNetworkSubnetConfig -Name $subnetAksName -AddressPrefix $subnetAksPrefix
$subnetConfigCassandra = New-AzVirtualNetworkSubnetConfig -Name $subnetCassandraName -AddressPrefix $subnetCassandraPrefix

$vnet = New-AzVirtualNetwork -ResourceGroupName $rgNetwork -Location $location `
    -Name $vnetPocName `
    -AddressPrefix $vnetPrefix `
    -Subnet $subnetConfigVms,$subnetConfigPe,$subnetConfigAks,$subnetConfigCassandra `
    -Tag $tags

Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetVmsName -AddressPrefix $subnetVmsPrefix -NetworkSecurityGroup $nsg

#Create Public IP address for the load balancer of vms
$pipElb = New-AzPublicIpAddress -ResourceGroupName $rgVms -Name $pipElbVms -Location $location -AllocationMethod static -SKU Standard -Tag $tags

#Create External Load Balancer of vms
$feElb = New-AzLoadBalancerFrontendIpConfig -Name $feElbVms -PublicIpAddress $pipElb
$bePool = New-AzLoadBalancerBackendAddressPoolConfig -Name $bePollElbVMs 
$natRule1 = New-AzLoadBalancerInboundNatRuleConfig -Name $("ssh-$vm1Name") -FrontendIpConfiguration $feElb -Protocol tcp -FrontendPort 9021 -BackendPort 22

$lb = New-AzLoadBalancer -ResourceGroupName $rgVms -Name $elbVms `
  -SKU Standard `
  -Location $location `
  -FrontendIpConfiguration $feElb `
  -BackendAddressPool $bepool `
  -InboundNatRule $natRule1 `
  -Tag $tags

#Create VMs
$nicVm1 = New-AzNetworkInterface -ResourceGroupName $rgVms -Location $location `
  -Name $("nic-$vm1Name") `
  -LoadBalancerBackendAddressPool $bePool `
  -LoadBalancerInboundNatRule $natRule1 `
  -Subnet $vnet.Subnets[0] `
  -Tag $tags

#Set an administrator username and password for the VMs
$cred = Get-Credential

#Create a virtual machine
$vmConfig = New-AzVMConfig -VMName $vm1Name -VMSize $vm1Size `
 | Set-AzVMBootDiagnostic -Disable `
 | Set-AzVMOperatingSystem -Linux -ComputerName $vm1Name -Credential $cred `
 | Set-AzVMSourceImage -PublisherName Canonical -Offer "0001-com-ubuntu-server-jammy" -Skus "22_04-lts-gen2" -Version latest `
 | Add-AzVMNetworkInterface -Id $nicVM1.Id

$vm1 = New-AzVM -ResourceGroupName $rgVms -Location $location -VM $vmConfig -Tag $tags

#Create Log Analytics
New-AzOperationalInsightsWorkspace -Location $location -Name $logAnalyticsName -ResourceGroupName $rgServices

#Create AKS
$laId = (Get-AzOperationalInsightsWorkspace -Name $logAnalyticsName -ResourceGroupName $rgServices).ResourceId
$vnetInfo = Get-AzVirtualNetwork -ResourceGroupName $rgNetwork -Name $vnetPocName
$subnetAksInfo = $vnetInfo.Subnets[0].Id

New-AzAksCluster -ResourceGroupName $rgAks `
    -Name $aksName `
    -EnableManagedIdentity `
    -NodeCount 1 `
    -NodeVmSize $nodSize `
    -NodeResourceGroup $rgMsftAks `
    -WorkspaceResourceId $laId `
    -NetworkPlugin kubenet `
    -SubnetName $subnetAksInfo `
    -ServiceCidr "192.168.0.0/16" `
    -DnsServiceIp "192.168.0.10" `
    -GenerateSshKey `
    -Tag $tags `
    -Force

$aks = Get-AzAksCluster -Name $aksName -ResourceGroupName $rgAks
