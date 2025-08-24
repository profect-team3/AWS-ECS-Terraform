data "aws_secretsmanager_secret" "exec_allowed" {
  for_each = var.secret_names
  name     = each.value
}

locals {
  exec_allowed_secret_arns = [for s in data.aws_secretsmanager_secret.exec_allowed : s.arn]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# ecs_task_execution 기본
resource "aws_iam_policy" "ecs_task_execution_policy" {
  name = "${var.name}-ecsTaskExecutionPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

# ecs_task_execution_secrets
resource "aws_iam_policy" "ecs_task_execution_secrets_policy" {
  name = "${var.name}-ecsTaskExecutionSecrets"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Secrets 읽기
      {
        Sid: "AllowReadServiceSecretsForEnvInjection",
        Effect: "Allow",
        Action: ["secretsmanager:GetSecretValue"],
        Resource: local.exec_allowed_secret_arns
      },
      # KMS 복호화
      {
        Sid: "AllowKmsDecryptForSecrets",
        Effect: "Allow",
        Action: ["kms:Decrypt"],
        Resource: [var.kms_key_arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_secrets_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_secrets_policy.arn
}


resource "aws_iam_role" "ecs_task_role" {
  for_each = var.service_definitions
  name = "${var.name}-ecsTaskRole-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}
