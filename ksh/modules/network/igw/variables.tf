variable "vpc_id" {
  description = "VPC ID - IGW"
  type        = string
}

variable "tags" {
  description = "Common tags (map)"
  type        = map(string)
  default     = {}
}