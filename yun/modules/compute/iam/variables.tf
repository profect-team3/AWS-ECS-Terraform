variable "name"     { type = string }
variable "region"  { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}


variable "services" {
  description = "ECS 서비스 이름 목록 (ecs-service 모듈의 service_definitions 키와 동일해야 함)"
  type        = list(string)
}

# ---- Execution Role 구성 ----
variable "create_execution_role_per_service" {
  description = "true = 서비스별 Execution Role 생성, false = 공유 Execution Role 1개만 생성"
  type        = bool
  default     = true
}

variable "exec_extra_policy_arns" {
  description = "Execution Role에 추가로 붙일 AWS 관리형/커스텀 정책 ARNs (모든 서비스 공통)"
  type        = list(string)
  default     = []
}

# Execution Role이 Secrets/Parameters를 가져올 때 필요한 권한(옵션)
#  - ECS 'secrets' 사용 시, 보통 'execution role'에 secrets 접근 권한이 필요합니다.
# variable "exec_secret_arns_global" {
#   description = "공유 Execution Role(또는 각 서비스 Execution Role)에 허용할 SecretsManager/SSM Parameter ARNs"
#   type        = list(string)
#   default     = []
# }

# variable "exec_secret_arns" {
#   description = "서비스별 Secrets/Parameters 접근 허용 (서비스별로 차등 권한 부여)"
#   type        = map(list(string))
#   default     = {}
# }

# variable "exec_kms_key_arns_global" {
#   description = "Secrets/Parameters 복호화를 위한 KMS Key ARNs (공유/서비스별 Execution Role에 부여)"
#   type        = list(string)
#   default     = []
# }

# variable "exec_kms_key_arns" {
#   description = "서비스별 KMS Key ARNs"
#   type        = map(list(string))
#   default     = {}
# }

# ---- Task Role 구성 ----
variable "task_role_policy_arns" {
  description = "서비스별 Task Role에 부착할 정책 ARNs"
  type        = map(list(string))
  default     = {}
}

variable "task_role_inline_policies" {
  description = <<EOT
서비스별 Task Role에 붙일 Inline Policy (JSON 문자열).
예: {
  user  = jsonencode({ Version="2012-10-17", Statement=[{...}] }),
  order = jsonencode({ ... })
}
EOT
  type    = map(string)
  default = {}
}

# ---- Permissions Boundary (옵션) ----
variable "permissions_boundary_arn" {
  description = "모든 생성 IAM Role에 공통으로 적용할 Permissions Boundary (옵션)"
  type        = string
  default     = null
}
