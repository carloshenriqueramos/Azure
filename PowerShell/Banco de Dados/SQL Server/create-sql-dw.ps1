# Sign-in to Azure via Azure Resource Manager

Connect-azaccount

# Select Azure Subscription

    $subscriptionId = 
        ( Get-AzSubscription |
            Out-GridView `
              -Title "Select an Azure Subscription ..." `
              -PassThru
        ).SubscriptionId

    Select-AzSubscription `
        -SubscriptionId $subscriptionId

# Select Azure Resource Group

    $rgName =
        ( Get-AzResourceGroup |
            Out-GridView `
              -Title "Select an Azure Resource Group ..." `
              -PassThru
        ).ResourceGroupName

$cred = Get-Credential

New-AzSqlServer -ResourceGroupName $rgName -ServerName "sqldwsrv01" -Location "southeastasia" -ServerVersion "12.0" -SqlAdministratorCredentials $cred -Debug

New-AzSqlDatabase -ResourceGroupName $rgName -RequestedServiceObjectiveName "DW400" -DatabaseName "sqldwdb01" -ServerName "sqldwsrv01"  -Edition "DataWarehouse" -CollationName "SQL_Latin1_General_CP1_CI_AS" -MaxSizeBytes 10995116277760 -Debug

New-AzSqlServerFirewallRule -ResourceGroupName $rgName -ServerName "sqldwsrv01" -AllowAllAzureIPs -Debug