## Lista Reservas e concede permissão

RESERVATION_ORDERS=$(az reservations reservation-order list --query '[].id' -o tsv)

for ITEM in $RESERVATION_ORDERS; do
	az role assignment create --assignee "{AZURE_AD_GROUP_OBJECT_ID}" --role "Owner" --scope $ITEM --verbose
done