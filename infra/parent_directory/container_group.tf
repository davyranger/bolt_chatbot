module "container_group" {
  source             = "../modules/container_group"
  resource_group     = module.container.rg_id
  user_assigned_id   = module.container.uai_id
  container_registry = module.container.cg_id
  slack_bot_token    = var.slack_bot_token
  slack_app_token    = var.slack_app_token

  depends_on = [
    module.container
  ]
}