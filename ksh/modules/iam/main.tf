# IAM 그룹
resource "aws_iam_group" "admin" {
  name = "${var.project_name}-admin"
  tags = var.tags
}

resource "aws_iam_group_policy_attachment" "admin_attach" {
  group      = aws_iam_group.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# IAM 역할
resource "aws_iam_role" "bedrock_execution_role_1" {
  name               = "${var.project_name}-AmazonBedrockExecutionRoleForAgents_FTK15XXF594"
  assume_role_policy = data.aws_iam_policy_document.bedrock_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role" "bedrock_execution_role_2" {
  name               = "${var.project_name}-AmazonBedrockExecutionRoleForAgents_HA07UOPINF"
  assume_role_policy = data.aws_iam_policy_document.bedrock_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role" "aoss_service_role" {
  name               = "${var.project_name}-AWSServiceRoleForAmazonOpenSearchServerless"
  assume_role_policy = data.aws_iam_policy_document.service_role.json
  tags               = var.tags
}

resource "aws_iam_role" "apigateway_service_role" {
  name               = "${var.project_name}-AWSServiceRoleForAPIGateway"
  assume_role_policy = data.aws_iam_policy_document.service_role.json
  tags               = var.tags
}

resource "aws_iam_role" "support_service_role" {
  name               = "${var.project_name}-AWSServiceRoleForSupport"
  assume_role_policy = data.aws_iam_policy_document.service_role.json
  tags               = var.tags
}

resource "aws_iam_role" "trustedadvisor_service_role" {
  name               = "${var.project_name}-AWSServiceRoleForTrustedAdvisor"
  assume_role_policy = data.aws_iam_policy_document.service_role.json
  tags               = var.tags
}

resource "aws_iam_role" "my_lambda_role" {
  name               = "${var.project_name}-my-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.tags
}

# IAM 정책 (고객 관리형만 예시)
resource "aws_iam_policy" "bedrock_policy_1" {
  name   = "AmazonBedrockAgentBedrockFoundationModelPolicy_ITPVP0I7RX"
  policy = file("${path.module}/policies/bedrock_policy_1.json")
  tags   = var.tags
}

resource "aws_iam_policy" "bedrock_policy_2" {
  name   = "AmazonBedrockAgentBedrockFoundationModelPolicy_S99SM3HD41"
  policy = file("${path.module}/policies/bedrock_policy_2.json")
  tags   = var.tags
}

# IAM 사용자
resource "aws_iam_user" "sunhyeok" {
  name = "sunhyeok"
  tags = var.tags
}

resource "aws_iam_user" "yunjoo" {
  name = "yunjoo"
  tags = var.tags
}

# 사용자 그룹 연결
resource "aws_iam_user_group_membership" "sunhyeok_group" {
  user   = aws_iam_user.sunhyeok.name
  groups = [aws_iam_group.admin.name]
}

resource "aws_iam_user_group_membership" "yunjoo_group" {
  user   = aws_iam_user.yunjoo.name
  groups = [aws_iam_group.admin.name]
}

# Assume Role Policy Documents
data "aws_iam_policy_document" "bedrock_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "service_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["*"]
    }
  }
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
