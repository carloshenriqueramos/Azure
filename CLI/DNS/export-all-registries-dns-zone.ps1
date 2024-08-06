az login
az account set --subscription ""

az network dns zone export -g rg-dns -n "dns zone" -f DNS.txt