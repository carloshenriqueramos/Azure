#Set subscription
$subname = read-host "Enter subscription name" 
Set-azcontext $subname

#Get All Sub Webapps
$apps =get-azwebapp

$output = @()

foreach($app in $apps){
    $output += New-Object PSObject -property $([ordered]@{ 
        Name = $app.name
        Hostnames = $app.hostnames -join ","
        State = $app.state
        Location = $app.Location
        Kind = $app.Kind
        Type = $app.Type
        LinuxFXConfig = $app.siteconfig.linuxfxversion
        WindowsFXConfig = $app.siteconfig.windowsfxversion
    })
}
 
$output