# terraform {
#   backend "s3" {
#     bucket         = "demo-tfstate-dev"
#     key            = "network/terraform.tfstate"
#     region         = "ap-northeast-2"
#     dynamodb_table = "demo-tflock-dev"
#     encrypt        = true
#   }
# }
