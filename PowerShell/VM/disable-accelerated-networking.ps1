az login
az account set --subscription SUBNAME

az network nic update --name VMNAME --resource-group RGNAME --accelerated-networking false