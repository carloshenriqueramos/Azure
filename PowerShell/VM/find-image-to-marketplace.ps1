Connect-AzAccount

Get-AzVMImagePublisher -Location BrazilSouth | Select PublisherName
Get-AzVMImageOffer -Location BrazilSouth -Publisher $pubName | Select Offer
Get-AzVMImageSku -Location BrazilSouth -Publisher $pubName -Offer $offerName | Select Skus