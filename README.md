# Infrastructure as Code

Notes that can be useful when deploying.

## Deploy from prompt

It is best practice to test your Bicep before commiting to the repo, just like
we do with all other code. In normal testing you run your application locally, 
but that is not possible for a Bicep script.

To deploy your infrastructure use the command below.

`az deployment group create --resource-group artnotiser-dev --template-file .\main.bicep` 

## Register Resource Providers
If you have a completely new subscription (like I did) when starting this project
you will not be able to run the deployment because you cannot create the type
of resources that is used by this solution.

You will get this error message: 
`Code: NoRegisteredProviderFound
Message: No registered resource provider found for location {location}
and API version {api-version} for type {resource-type}.`

```
az login 

az provider register --namespace Microsoft.AppConfiguration
az provider register --namespace Microsoft.Insights
az provider register --namespace Microsoft.DocumentDB
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Web
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.ServiceBus
```

https://learn.microsoft.com/en-us/azure/azure-resource-manager/troubleshooting/error-register-resource-provider?tabs=azure-cli

## Purge old Key Vaults
If you have cleaned your environment to do a commpletely fresh deployment you may 
run into this problem during deployment: `The vault name 'kv-artnotiser-dev' is already in use. Vault names are globaly unique so it is possible that the name is already taken. If you are sure that the vault name was not taken then it is possible that a vault with the same name was recently deleted but not purged after being placed in a recoverable state. If the vault is in a recoverable state then the vault will need to be purged before reusing the name. For more information about VaultAlreadyExists, soft delete and purging a vault follow this link https://go.microsoft.com/fwlink/?linkid=2147740`

This is due to that Key Vaults created by ArtNotiser has Soft-Delete enabled 
which makes the Key Vault and its content recoverable for 90 days (by default).

If you are a subscription Owner you can run `az keyvault purge --subscription 
{subscription id} --n {key vault name}` to remove the Key Vault.

If you want to see all Key Vaults that are soft-deleted you can execute 
`az keyvault list-deleted --subscription {subscription id} --resource-type vault`

## Remove old storage accounts

Storage accounts are by default soft-deleted for 14 days, then they are
automatically removed.

`"code": "StorageAccountAlreadyTaken", "target": "saartnotiserdev5", "message": "The storage account named saartnotiserdev5 is already taken."`

## CosmosDb Database fails to create

Even though the CosmosDB Database has a dependency to the CosmosDB Account
through the `parent` property it can fail with the error below.
`"The requested operation cannot be performed because the database account cdb-artnotiser-dev state is not Online."`

I don't have a solution for this, but running it again will work because
then the CosmosDB Account has come fully online.