variable "cognito_username" {
  description = "username login credentials for cognito"
  type        = string

}

variable "cognito_password" {
  description = "password login credentials for cognito"
  type        = string
  sensitive   = true
}