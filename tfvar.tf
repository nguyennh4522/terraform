resource "random_string" "dns" {
  length  = 8
  lower   = true
  special = false
}

variable "AWS_REGION" {
  type        = string
  default     = "ap-southeast-2"
  description = "AWS region where the provider will operate"
}

variable "VALIDATOR_ADDR" {
  type = string
}

variable "VALIDATOR_WALLET_PRIVATE_KEY" {
  type = string
}
