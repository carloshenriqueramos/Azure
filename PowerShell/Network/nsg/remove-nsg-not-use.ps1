$inputfile = "c:\temp\nsgorfao.csv"
$data=Import-Csv -Path $inputfile
foreach ($nsg in $data)
{
$nsgname=$nsg.nsg
$rg=$nsg.rg
 
remove-aznetworksecuritygroup -name $nsgname -resourcegroupname $rg -force
}