locals {
  services_set = toset(var.services)
  exec_each_set = var.create_execution_role_per_service ? toset(var.services) : toset([])

  # 서비스별 secrets / kms key 리스트를 병합(서비스별 + 글로벌)
  # exec_secrets_merged = {
  #   for s in var.services :
  #   s => concat(lookup(var.exec_secret_arns, s, []), var.exec_secret_arns_global)
  # }
  #
  # exec_kms_merged = {
  #   for s in var.services :
  #   s => concat(lookup(var.exec_kms_key_arns, s, []), var.exec_kms_key_arns_global)
  # }
}

# ---- Assume Role Policy (ECS Tasks) ----
data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# (A) 서비스별 Execution Role
resource "aws_iam_role" "exec" {
  for_each             = local.exec_each_set
  name               = "${var.name}-${each.key}-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
  permissions_boundary = var.permissions_boundary_arn != null ? var.permissions_boundary_arn : null
  tags               = merge(var.tags, {
    Role = "exec"
    Service = each.key
  })
}

# 기본 Execution Role 정책 (ECR Pull, Logs 등)
resource "aws_iam_role_policy_attachment" "exec_base" {
  for_each   = aws_iam_role.exec
  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 추가 Execution Role 관리형 정책 공통 부착
resource "aws_iam_role_policy_attachment" "exec_extra" {
  for_each = {
    for pair in flatten([
      for svc in keys(aws_iam_role.exec) : [
        for p in var.exec_extra_policy_arns : { svc = svc, policy = p }
      ]
    ]) : "${pair.svc}:${pair.policy}" => pair
  }
  role       = aws_iam_role.exec[each.value.svc].name
  policy_arn = each.value.policy
}

# Secrets/Parameters & KMS 권한(서비스별 Execution Role)
# resource "aws_iam_role_policy" "exec_secrets" {
#   for_each = {
#     for s, arns in local.exec_secrets_merged :
#     s => arns if var.create_execution_role_per_service && length(arns) > 0
#   }
#
#   name = "${var.name}-${each.key}-exec-secrets"
#   role = aws_iam_role.exec[each.key].id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = concat(
#         length(each.value) > 0 ? [{
#         Sid      = "AllowReadSecretsAndParams"
#         Effect   = "Allow"
#         Action   = [
#           "secretsmanager:GetSecretValue",
#           "ssm:GetParameter",
#           "ssm:GetParameters",
#           "ssm:GetParametersByPath"
#         ]
#         Resource = each.value
#       }] : [],
#         length(local.exec_kms_merged[each.key]) > 0 ? [{
#         Sid      = "AllowKMSDecryptForSecrets"
#         Effect   = "Allow"
#         Action   = ["kms:Decrypt"]
#         Resource = local.exec_kms_merged[each.key]
#       }] : []
#     )
#   })
# }

# (B) 공유 Execution Role 1개
resource "aws_iam_role" "exec_shared" {
  count              = var.create_execution_role_per_service ? 0 : 1
  name               = "${var.name}-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
  permissions_boundary = var.permissions_boundary_arn != null ? var.permissions_boundary_arn : null
  tags               = merge(var.tags, { Role = "exec", Scope = "shared" })
}

resource "aws_iam_role_policy_attachment" "exec_base_shared" {
  count      = length(aws_iam_role.exec_shared) == 1 ? 1 : 0
  role       = aws_iam_role.exec_shared[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "exec_extra_shared" {
  for_each = {
    for p in var.exec_extra_policy_arns :
    p => p if length(aws_iam_role.exec_shared) == 1
  }
  role       = aws_iam_role.exec_shared[0].name
  policy_arn = each.value
}

# resource "aws_iam_role_policy" "exec_secrets_shared" {
#   count = length(aws_iam_role.exec_shared) == 1 && length(var.exec_secret_arns_global) > 0 ? 1 : 0
#
#   name = "${var.name}-exec-secrets"
#   role = aws_iam_role.exec_shared[0].id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = concat(
#         length(var.exec_secret_arns_global) > 0 ? [{
#         Sid      = "AllowReadSecretsAndParams"
#         Effect   = "Allow"
#         Action   = [
#           "secretsmanager:GetSecretValue",
#           "ssm:GetParameter",
#           "ssm:GetParameters",
#           "ssm:GetParametersByPath"
#         ]
#         Resource = var.exec_secret_arns_global
#       }] : [],
#         length(var.exec_kms_key_arns_global) > 0 ? [{
#         Sid      = "AllowKMSDecryptForSecrets"
#         Effect   = "Allow"
#         Action   = ["kms:Decrypt"]
#         Resource = var.exec_kms_key_arns_global
#       }] : []
#     )
#   })
# }

# =========================================================
# ========================  TASK ROLE  ====================
# =========================================================

resource "aws_iam_role" "task" {
  for_each             = local.services_set
  name                 = "${var.name}-${each.key}-task"
  assume_role_policy   = data.aws_iam_policy_document.ecs_tasks_assume.json
  permissions_boundary = var.permissions_boundary_arn != null ? var.permissions_boundary_arn : null
  tags                 = merge(var.tags, {
    Role = "task"
    Service = each.key
  })
}

# 서비스별 관리형 정책 attach
resource "aws_iam_role_policy_attachment" "task_managed" {
  for_each = {
    for pair in flatten([
      for svc in var.services : [
        for p in lookup(var.task_role_policy_arns, svc, []) : { svc = svc, policy = p }
      ]
    ]) : "${pair.svc}:${pair.policy}" => pair
  }
  role       = aws_iam_role.task[each.value.svc].name
  policy_arn = each.value.policy
}

# 서비스별 Inline Policy attach (JSON 문자열 그대로)
resource "aws_iam_role_policy" "task_inline" {
  for_each = {
    for svc, pol in var.task_role_inline_policies :
    svc => pol if contains(var.services, svc)
  }
  name   = "${var.name}-${each.key}-task-inline"
  role   = aws_iam_role.task[each.key].id
  policy = each.value
}
