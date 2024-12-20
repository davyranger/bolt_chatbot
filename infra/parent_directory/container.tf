module "container" {
  source                = "../modules/container"
  azure_subscription_id = var.azure_subscription_id
  azure_client_id       = var.azure_client_id
  azure_tenant_id       = var.azure_tenant_id
  slack_bot_token_http  = var.slack_bot_token_http
  slack_app_token_http  = var.slack_app_token_http
  ngrok_authtoken       = var.ngrok_authtoken
}