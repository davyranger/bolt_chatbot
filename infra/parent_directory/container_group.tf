module "container_group" {
  source                  = "../modules/container_group"
  resource_group_id       = module.container.rg_id
  resource_group_name     = module.container.rg_name
  resource_group_location = module.container.rg_location
  container_registry      = module.container.cg_id
  slack_bot_token_http    = var.slack_bot_token_http
  slack_app_token_http    = var.slack_app_token_http
  azure_subscription_id   = var.azure_subscription_id
  ngrok_authtoken         = var.ngrok_authtoken
  
  depends_on = [
    module.container
  ]
}