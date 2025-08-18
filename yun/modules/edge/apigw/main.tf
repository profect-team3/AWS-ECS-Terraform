# REST API
resource "aws_api_gateway_rest_api" "this" {
  name = var.name
  endpoint_configuration { types = ["REGIONAL"] }
  tags = var.tags
}


# VPC Link
resource "aws_api_gateway_vpc_link" "vpclink" {
  name        = "${var.name}-vpclink"
  target_arns = [var.nlb_arn]
  tags        = var.tags
}

# ANY /{proxy+}
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_any" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}


# # (선택) 개별 경로 ANY
# resource "aws_api_gateway_resource" "paths" {
#   for_each    = toset(var.paths)
#   rest_api_id = aws_api_gateway_rest_api.this.id
#   parent_id   = aws_api_gateway_rest_api.this.root_resource_id
#   path_part   = each.value
# }
#
# resource "aws_api_gateway_method" "paths_any" {
#   for_each      = aws_api_gateway_resource.paths
#   rest_api_id   = aws_api_gateway_rest_api.this.id
#   resource_id   = each.value.id
#   http_method   = "ANY"
#   authorization = "NONE"
# }
#
# resource "aws_api_gateway_integration" "paths_int" {
#   for_each                = aws_api_gateway_method.paths_any
#   rest_api_id             = each.value.rest_api_id
#   resource_id             = each.value.resource_id
#   http_method             = each.value.http_method
#   type                    = "HTTP_PROXY"
#   integration_http_method = "ANY"
#   connection_type         = "VPC_LINK"
#   connection_id           = aws_api_gateway_vpc_link.vpclink.id
#   uri                     = "http://${var.nlb_dns_name}:${var.nlb_port}/${each.key}"
# }
#
# resource "aws_api_gateway_integration" "proxy_int" {
#   rest_api_id             = aws_api_gateway_rest_api.this.id
#   resource_id             = aws_api_gateway_resource.proxy.id
#   http_method             = aws_api_gateway_method.proxy_any.http_method
#   type                    = "HTTP_PROXY"
#   integration_http_method = "ANY"
#   connection_type         = "VPC_LINK"
#   connection_id           = aws_api_gateway_vpc_link.vpclink.id
#   uri                     = "http://${var.nlb_dns_name}:${var.nlb_port}/{proxy}"
#
#   request_parameters = {
#     "integration.request.path.proxy" = "method.request.path.proxy"
#   }
# }

#
# # 배포
# resource "aws_api_gateway_deployment" "dep" {
#   rest_api_id = aws_api_gateway_rest_api.this.id
#   triggers = {
#     redeploy = sha1(jsonencode([
#       aws_api_gateway_integration.proxy_int.id,
#       values(aws_api_gateway_integration.paths_int)[*].id
#     ]))
#   }
#   lifecycle { create_before_destroy = true }
# }
#
# resource "aws_api_gateway_stage" "stage" {
#   rest_api_id   = aws_api_gateway_rest_api.this.id
#   stage_name    = var.stage_name
#   deployment_id = aws_api_gateway_deployment.dep.id
#   description   = var.description
#   tags          = local.tags
# }
#
# # 커스텀 도메인 + 매핑
# resource "aws_api_gateway_domain_name" "domain" {
#   domain_name              = var.domain_name
#   regional_certificate_arn = var.certificate_arn
#   endpoint_configuration { types = ["REGIONAL"] }
#   tags = local.tags
# }
#
# resource "aws_api_gateway_base_path_mapping" "map" {
#   api_id      = aws_api_gateway_rest_api.this.id
#   stage_name  = aws_api_gateway_stage.stage.stage_name
#   domain_name = aws_api_gateway_domain_name.domain.domain_name
# }