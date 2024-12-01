variable "resource_group" {
  description = "Resource Group ID"
  type        = string
}
variable "user_assigned_id" {
  description = "User Assigned Identity Principal ID"
  type        = string
}
variable "container_registry" {
  description = "Container Registry ID"
  type        = string
}

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