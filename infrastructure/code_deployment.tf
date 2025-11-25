# Data source to get the function app zip file
data "archive_file" "function_app_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../app/dist"
  output_path = "${path.module}/.terraform/function-app.zip"

  # Only regenerate the zip if any source files change
  depends_on = [null_resource.build_function_app]
}

# Local-exec provisioner to build the TypeScript function app
resource "null_resource" "build_function_app" {
  triggers = {
    # Rebuild if any TypeScript source files change
    typescript_files = filemd5sum("${path.module}/../app/src/functions/httpTrigger.ts")
    package_json     = filemd5sum("${path.module}/../app/package.json")
    tsconfig         = filemd5sum("${path.module}/../app/tsconfig.json")
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/../app && npm install && npm run build"
  }
}

# Upload the function app zip to the storage account blob container
resource "azurerm_storage_blob" "function_app_code" {
  name                   = "function-app-${formatdate("YYYY-MM-DD-hhmm", timestamp())}.zip"
  storage_account_name   = azurerm_storage_account.function_storage.name
  storage_container_name = azurerm_storage_container.function_deployments.name
  type                   = "Block"
  source                 = data.archive_file.function_app_zip.output_path

  depends_on = [
    data.archive_file.function_app_zip,
    null_resource.build_function_app
  ]
}

resource "null_resource" "deploy_function_app_zip" {
  triggers = {
    zip_file_hash = data.archive_file.function_app_zip.output_base64sha256
  }

  provisioner "local-exec" {
    command = "az functionapp deployment source config-zip --resource-group '${data.azurerm_resource_group.rg.name}' --name '${azurerm_linux_function_app.function_app.name}' --src '${data.archive_file.function_app_zip.output_path}'"
  }

  depends_on = [
    azurerm_linux_function_app.function_app,
    data.archive_file.function_app_zip
  ]
}

output "function_app_code_blob_url" {
  value       = azurerm_storage_blob.function_app_code.url
  description = "URL to the uploaded function app zip file in blob storage"
}

output "function_app_code_sas_url" {
  value       = local.function_app_code_sas_url
  sensitive   = true
  description = "SAS URL for accessing the function app zip file"
}
