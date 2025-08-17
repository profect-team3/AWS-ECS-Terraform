output "admin_group_id" {
  value = aws_iam_group.admin.id
}

output "iam_users" {
  value = [aws_iam_user.sunhyeok.name, aws_iam_user.yunjoo.name]
}

output "roles" {
  value = [
    aws_iam_role.bedrock_execution_role_1.name,
    aws_iam_role.bedrock_execution_role_2.name,
    aws_iam_role.aoss_service_role.name,
    aws_iam_role.apigateway_service_role.name,
    aws_iam_role.support_service_role.name,
    aws_iam_role.trustedadvisor_service_role.name,
    aws_iam_role.my_lambda_role.name
  ]
}

output "policies" {
  value = [
    aws_iam_policy.bedrock_policy_1.arn,
    aws_iam_policy.bedrock_policy_2.arn
  ]
}