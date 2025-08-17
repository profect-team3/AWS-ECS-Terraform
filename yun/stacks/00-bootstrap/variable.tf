variable "project"             { type = string }
variable "env"                 { type = string }
variable "region" {
  description = "AWS 리전"
  type        = string
}
variable "tags" {
  description = "공통 태그 맵"
  type        = map(string)
  default     = {}
}
