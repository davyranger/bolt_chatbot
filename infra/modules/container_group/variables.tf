variable "resource_group_id" {
  description = "Resource Group ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "resource_group_location" {
  description = "Resource Group Location"
  type        = string
}
variable "container_registry" {
  description = "Container Registry ID"
  type        = string
}

variable "slack_bot_token_http" {
  description = "Slack Bot Token"
  type        = string
  sensitive   = true # Marks this as sensitive to prevent showing in logs
}

variable "slack_app_token_http" {
  description = "Slack App Token"
  type        = string
  sensitive   = true # Marks this as sensitive to prevent showing in logs
}
variable "azure_subscription_id" {
  type      = string
  sensitive = true
}