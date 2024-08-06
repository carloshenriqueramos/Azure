Login-AzureRmAccount

Select-AzSubscription -SubscriptionName "name-of-subscription"

$vnetGw = Get-AzVirtualNetworkGateway -ResourceGroupName "resource-group-name" -Name "vnet-gateway-name"

Resize-AzVirtualNetworkGateway -VirtualNetworkGateway $vnetGw -GatewaySku HighPerformance