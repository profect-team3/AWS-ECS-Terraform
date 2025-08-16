variable "vpc_id" {
  description = "VPC ID - subnet"
  type        = string
}

variable "cidr" {
  description = "List of CIDR Blocks - subnets"
  type        = list(string)
}

variable "azs" {
  description = "List of Availability zones - subnets"
  type        = list(string)
}

variable "public" {
  description = "Public - Subnets"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags - Subnets"
  type        = map(string)
  default     = {}
}