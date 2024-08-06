$inputfile = "c:\temp\nicorfa.csv"
$data=Import-Csv -Path $inputfile
foreach ($nic in $data)
{
$nicname=$nic.nic
$rg=$nic.rg
 
remove-aznetworkinterface -name $nicname -resourcegroupname $rg -force
}