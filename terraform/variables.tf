variable "container" {
  type        = any
  default     = "particule/helloworld"
  description = "Container configuration to deploy"
}

variable "dns_name" {
  type    = any
  default = {}
}

variable "hosted_zone" {
  type    = any
  default = {}
}

variable "domain_suffix" {
  type    = any
  default = {}
}