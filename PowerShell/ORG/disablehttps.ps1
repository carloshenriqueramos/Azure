Connect-AzAccount


$lista = (get-content C:\temp\waandfa.txt.txt)

$apps =  get-azwebapp

foreach ($app in $apps){

    foreach ($list in $lista){

        if ($app.Name -eq $list) {
            
            Set-AzWebApp -Name $app.Name -ResourceGroupName $app.ResourceGroup -HttpsOnly $False

         }

    }

}