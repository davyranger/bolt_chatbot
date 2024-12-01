module "container" {
  source                = "../modules/container"
  azure_subscription_id = var.azure_subscription_id
  azure_client_id       = var.azure_client_id
  azure_client_secret   = var.azure_client_secret
  azure_tenant_id       = var.azure_tenant_id
  slack_bot_token       = var.slack_bot_token
  slack_app_token       = var.slack_app_token
}