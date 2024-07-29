# Comandos do dia a dia

# Lista os Resource Groups que possuem determinada Tag
Get-AzResourceGroup -Tag @{ "Team" = "Dev" ; "Environment" = "Dev" } | ft

# Lista todas as Tags do Resource Group
(Get-AzResourceGroup "rgname").Tags

# Lista todos os recursos que possuem determinada Tag
Get-AzResource -Name "tagname" | ft

# Lista todos os recursos que possuem determinada Tag
Get-AzResource -TagName "Environment" -TagValue "Dev"

# Lista todos os recursos que possuem determinada Tag
Get-AzResource -Tag @{ "Team" = "Dev" ; "Environment" = "Dev" }

# Lista todos os recursos que possuem determinada Tag
Get-AzResource -TagName "Environment"

# Lista todos os recursos que possuem determinada Tag
Get-AzResource -TagValue "Production"

# Lista todos os recursos que não possuem Tags
Get-AzResource | Select Type, Name, ResourceGroupName | where Tags -eq $null | Export-Csv C:\Sem_Tags.csv

# ----------------------------------------------------------------------------

# Atualizando Tags em Recursos

Connect-AzAccount
Set-AzContext -Subscription "SUBNAME"

# Definindo as novas Tags
$Tags = @{"Responsavel"="Equipe Infra"}

# Obtendo os recursos com as Tags que queremos atualizar
$resources = Get-AzResource -TagName "Responsavel" -TagValue "Equipe TI"

# Analisando cada recurso
$resources | ForEach-Object {
    # Atualizando as Tags
	Update-AzTag -ResourceId $_.ResourceId -Tag $Tags -Operation Merge
}

#----------------------------------------------------------------------------------------

# Atualiza Tags em Resource Group

Connect-AzAccount
Set-AzContext -Subscription "Equipe Infra"

# Definindo as novas Tags
$Tags = @{"E-mail"="user@newdominio.com"}

# Obtendo os recursos com as Tags que queremos atualizar
$resources = (Get-AzResourceGroup -Tag @{ "E-mail"="user@olddominio.com" })

# Analisando cada recurso
ForEach ($rg in $resources) { 
    # Atualizando as Tags    
    Update-AzTag -ResourceId $rg.ResourceId -Tag $Tags -Operation Merge 
}

#----------------------------------------------------------------------------------------

$tags = (Get-AzResourceGroup -Name "rgname").Tags
$tags.Add("Environment", "Dev")
Set-AzResourceGroup -Tag $tags -Name "rgname"

#----------------------------------------------------------------------------------------

# Removendo Tags em Resource Group

Connect-AzAccount

Set-AzContext -Subscription "SUBNAME"

# Definindo as Tags que seram removidas
$deletedTags = @{"Responsavel"="TI"}

# Obtendo os Resource Groups com as Tags que queremos atualizar
$resources = (Get-AzResourceGroup -Tag $deletedTags)

# Analisando cada recurso
$resources | foreach-object {
    # Atualizando as Tags 
    Update-AzTag -ResourceId $_.resourceid -Tag $deletedTags -Operation Delete
}

#----------------------------------------------------------------------------------------

# Atualiza Tags em Resource Group

$r = Get-AzResource -ResourceName tw-winsrv -ResourceGroupName "rgname"
Set-AzResource -Tag @{ Dept="IT"; Environment="Test" } -ResourceId $r.ResourceId -Force

$r = Get-AzResource -ResourceName tw-winsrv -ResourceGroupName "rgname"
$r.Tags.Add("Environment", "Dev")
Set-AzResource -Tag $r.Tags -ResourceId $r.ResourceId -Force

#----------------------------------------------------------------------------------------