variable "slack_bot_token" {
  description = "Slack Bot Token"
  type        = string
  sensitive   = true # Marks this as sensitive to prevent showing in logs
}

variable "slack_app_token" {
  description = "Slack App Token"
  type        = string
  sensitive   = true # Marks this as sensitive to prevent showing in logs
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
