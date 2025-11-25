resource "azurerm_service_plan" "function_plan" {
  name                = "${local.resource_name_prefix}-plan"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = var.function_app_os_type
  sku_name            = var.app_service_plan_sku

  tags = local.common_tags
}

resource "azurerm_linux_function_app" "function_app" {
  name                = var.function_app_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.function_plan.id

  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key

  app_settings = {
    "ENABLE_ORYX_BUILD"              = "true"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "FUNCTIONS_WORKER_RUNTIME"       = "node"
    "WEBSITE_NODE_DEFAULT_VERSION"   = "~${var.function_app_runtime_version}"
  }

  site_config {
    application_stack {
      node_version = var.function_app_runtime_version
    }

    # Enable CORS for APIM integration
    cors {
      allowed_origins     = ["*"]
      support_credentials = false
    }

    minimum_tls_version = "1.2"
    http2_enabled       = true
  }

  identity {
    type = "SystemAssigned"
  }

  https_only = true

  tags = local.common_tags

  depends_on = [
    azurerm_storage_account.function_storage
  ]
}

# Output the function app details for deployment
output "function_app_default_hostname" {
  value = azurerm_linux_function_app.function_app.default_hostname
}

output "function_app_id" {
  value = azurerm_linux_function_app.function_app.id
}

output "function_app_identity_principal_id" {
  value       = azurerm_linux_function_app.function_app.identity[0].principal_id
  description = "Principal ID for function app managed identity"
}
