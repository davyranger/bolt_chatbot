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

variable "slack_bot_token" {
  description = "Slack Bot Token"
  type        = string
  sensitive   = true # Marks this as sensitive to prevent showing in logs
}

variable "slack_signing_secret" {
  description = "Slack App Token"
  type        = string
  sensitive   = true # Marks this as sensitive to prevent showing in logs
}
variable "azure_subscription_id" {
  type      = string
  sensitive = true # Marks this as sensitive to prevent showing in logs
}

variable "ngrok_authtoken" {
  description = "Ngrok Auth Token"
  type        = string
  sensitive   = true # Marks this as sensitive to prevent showing in logs
}