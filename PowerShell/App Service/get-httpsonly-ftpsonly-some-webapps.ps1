# Connect ao Azure
Connect-AzAccount

$fileApps = (get-content C:\temp\waandfa.txt.txt)

$apps =  get-azwebapp

foreach ($app in $fileApps){

    $apps | Where-object { $_.Name -match $app } | Select Name, ResourceGroup, HttpsOnly, SiteConfig.FtpsState

}