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

# variable "acr_username" {
#   description = "container group username"
#   type        = string
#   sensitive   = true # Marks this as sensitive to prevent showing in logs
# }

# variable "acr_password" {
#   description = "container group password"
#   type        = string
#   sensitive   = true # Marks this as sensitive to prevent showing in logs
# }


