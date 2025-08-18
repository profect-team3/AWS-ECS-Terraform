variable "name" { type = string }
variable "tags"    {
  type = map(string)
  default = {}
}
variable "vpc_id" { type = string }
variable "public_subnet_ids"  { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "multi_nat" {
  type = bool
  default = false
}