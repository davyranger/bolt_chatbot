module "container_group" {
  source                  = "../modules/container_group"
  resource_group_id       = module.container.rg_id
  resource_group_name     = module.container.rg_name
  resource_group_location = module.container.rg_location
  # user_assigned_id        = module.container.uai_id
<<<<<<< HEAD
  container_registry    = module.container.cg_id
  slack_bot_token       = var.slack_bot_token
  slack_app_token       = var.slack_app_token
  azure_subscription_id = var.azure_subscription_id
=======
  container_registry      = module.container.cg_id
  slack_bot_token         = var.slack_bot_token
  slack_app_token         = var.slack_app_token
  azure_subscription_id   = var.azure_subscription_id
>>>>>>> 37d3ac421657c1cdfed38ff94dbbbb0451299037

  depends_on = [
    module.container
  ]
}