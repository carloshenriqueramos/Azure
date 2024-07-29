<#
.SYNOPSIS
Script para atualização de tags de recursos na Azure a partir de um arquivo Excel.

.PREREQUISITOS
- Módulo Az PowerShell instalado.
- Módulo ImportExcel instalado.
- Arquivo Excel contendo as tags e recursos.

.DESCRICAO
Este script permite atualizar as tags de recursos na Azure com base em um arquivo Excel. O arquivo Excel deve conter as seguintes colunas:
- Resource: Nome do recurso na Azure.
- OWNER: Proprietário do recurso.
- SUPPORT: Suporte do recurso.
- DESCRIPTION: Descrição do recurso.
- ENVIRONMENT: Ambiente do recurso.
- COST: Custo do recurso.
- CRITICAL: Criticidade do recurso.
- POWERSTART: Hora de início do recurso.
- POWERSTOP: Hora de parada do recurso.
- RESOURCEGROUP: Nome do grupo de recursos do recurso.

Criado por CARLOS MARQUES (carlos.marques@4mstech.com)
BEYONDSOFT BRASIL

.PASSOS
1. Ao executar o script, será solicitado a "Subscription ID". Ex: (9caa93b7-6a21-4989-94f6-f03ce9acd99b)
2. Será solicitado o caminho completo do arquivo Excel. Ex: (D:\Scripts\tags.xlsx)
3. Será exibido um resumo das alterações que serão realizadas.
4. Será solicitada uma confirmação para prosseguir com a atualização das tags.
5. Será solicitado o tipo de operação para a atualização das tags ("merge", "delete" ou "replace").
6. Após a confirmação, as tags serão atualizadas para cada recurso.
7. Ao final, será exibida uma mensagem informando que a atualização de tags foi concluída.

#>

# Conectando à sua conta do Azure
Connect-AzAccount

# Solicitando a Subscription ID
$subscriptionId = Read-Host "Informe a Subscription ID"

# Selecionando a assinatura
Select-AzSubscription -SubscriptionId $subscriptionId

# Solicitando o arquivo Excel
$filePath = Read-Host "Informe o caminho completo do arquivo Excel"

# Importando o arquivo Excel usando o módulo ImportExcel
try {
    Import-Module -Name ImportExcel
} catch {
    Write-Host "O módulo ImportExcel não está instalado. Por favor, instale-o executando 'Install-Module -Name ImportExcel' no PowerShell."
    return
}

try {
    $excelData = Import-Excel -Path $filePath
} catch {
    Write-Host "Erro ao importar o arquivo Excel. Verifique se o caminho do arquivo está correto e se o formato é suportado."
    return
}

$dataTable = $excelData | Select-Object -Property Resource, OWNER, SUPPORT, DESCRIPTION, ENVIRONMENT, COST, CRITICAL, POWERSTART, POWERSTOP, RESOURCEGROUP

# Exibindo um resumo das alteracoes que serão realizadas
Write-Host "Resumo das alterações:"
foreach ($row in $dataTable) {
    $resourceName = $row.Resource
    $tags = @{}

    foreach ($column in $row.PsObject.Properties) {
        $columnName = $column.Name
        $columnValue = $column.Value

        if ($columnName -ne "Resource" -and $columnValue -and $columnName -ne "RESOURCEGROUP") {
            $tags[$columnName] = $columnValue.ToString()
        }
    }

    Write-Host "Recurso: $resourceName"
    $tags.GetEnumerator() | ForEach-Object {
        Write-Host "- $($_.Key): $($_.Value)"
    }

    Write-Host
}

# Solicitando confirmacao para atualizacao das tags
$confirmation = Read-Host "Deseja prosseguir com a atualizacao das tags? (S/N)"

if ($confirmation.ToUpper() -ne "S") {
    Write-Host "Atualizacao das tags cancelada."
    return
}

# Solicitando o tipo de operacao para a atualizacao das tags
$operation = Read-Host "Informe o tipo de operacao para a atualizacao das tags (merge, delete ou replace)"

if ($operation -ne "merge" -and $operation -ne "delete" -and $operation -ne "replace") {
    Write-Host "Operacao inválida. A atualizacao das tags foi cancelada."
    return
}

# Iterando pelos recursos e tags no arquivo Excel
foreach ($row in $dataTable) {
    $resourceName = $row.Resource
    $tags = @{}

    foreach ($column in $row.PsObject.Properties) {
        $columnName = $column.Name
        $columnValue = $column.Value

        if ($columnName -ne "Resource" -and $columnValue -and $columnName -ne "RESOURCEGROUP") {
            $tags[$columnName] = $columnValue.ToString()
        }
    }

    # Exibindo as tags do recurso
    Write-Host "Recurso: $resourceName"
    $tags.GetEnumerator() | ForEach-Object {
        Write-Host "- $($_.Key): $($_.Value)"
    }

    # Buscando o ResourceId do recurso pelo nome
    $resource = Get-AzResource | Where-Object { $_.Name -eq $resourceName }

    if ($resource) {
        # Obtendo o nome do grupo de recursos do recurso
        $resourceGroupName = $row.RESOURCEGROUP
        if (-not $resourceGroupName) {
            # Caso o nome do grupo de recursos não tenha sido fornecido na tabela, buscamos o grupo de recursos correspondente ao recurso
            $resourceGroupName = $resource.ResourceGroupName
        }
        if ($resourceGroupName) {
            # Atualizando as tags do recurso
            Update-AzTag -Tag $tags -ResourceId $resource.Id -Operation $operation
            Write-Host "Tags atualizadas para o recurso $resourceName no grupo de recursos $resourceGroupName"
        } else {
            Write-Host "Nome do grupo de recursos não fornecido para o recurso $resourceName."
        }
    } else {
        Write-Host "Recurso $resourceName não encontrado na Azure."
    }

    Write-Host
}

Write-Host "Atualizacao de tags concluida."
