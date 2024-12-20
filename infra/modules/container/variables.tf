variable "slack_app_token_http" {
  type      = string
  sensitive = true
}

variable "slack_bot_token_http" {
  type      = string
  sensitive = true
}

variable "azure_client_id" {
  type      = string
  sensitive = true
}

variable "azure_tenant_id" {
  type      = string
  sensitive = true
}

variable "azure_subscription_id" {
  type      = string
  sensitive = true
}

variable "ngrok_authtoken" {
  type      = string
  sensitive = true
}
