variable "project_name" {
  type = string
  default = "Goorm3-project"
}

variable "env" {
  type = string
  default = "dev"
}

variable "tags" {
  type = map(string)
  default = {
    Owner = "Cloud"
    Env = "dev"
    Project_name = "Goorm3-project"
  }
}