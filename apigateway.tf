// the actual api 
resource "aws_api_gateway_rest_api" "api_gateway" {
  name = "my_api_gateway"
  description = "my api gateway"
  endpoint_configuration {
    types = [ "REGIONAL" ]
  }
}
// the url path the customer will hit 
resource "aws_api_gateway_resource" "root_path" {
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "mypath"
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}
//"Okay, if someone goes to /mypath and tries to POST, we will allow it, and here's how we’ll handle it."
resource "aws_api_gateway_method" "method_request" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.root_path.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
}
// When someone opens the /mypath door and uses the POST method, I’m gonna sneak them through this tunnel to the backend — whether that’s Lambda, a website, or just a fake test
resource "aws_api_gateway_integration" "integration_request" {
  http_method = aws_api_gateway_method.method_request.http_method
  resource_id = aws_api_gateway_resource.root_path.id
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  integration_http_method = "POST"
  type = "MOCK"
}
// If the person knocks correctly and gives me the right secret code (like 200), I will allow them to pass and see what's behind the door
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.root_path.id
  http_method = aws_api_gateway_method.method_request.http_method
  status_code = "200"
}
// Here’s your requested data!
resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.root_path.id
  http_method = aws_api_gateway_method.method_request.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
  depends_on = [ aws_api_gateway_method.method_request, aws_api_gateway_integration.integration_request ]
}

// options 










# resource "aws_api_gateway_deployment" "example" {
#   rest_api_id = aws_api_gateway_rest_api.example.id

#   triggers = {
#     # NOTE: The configuration below will satisfy ordering considerations,
#     #       but not pick up all future REST API changes. More advanced patterns
#     #       are possible, such as using the filesha1() function against the
#     #       Terraform configuration file(s) or removing the .id references to
#     #       calculate a hash against whole resources. Be aware that using whole
#     #       resources will show a difference after the initial implementation.
#     #       It will stabilize to only change when resources change afterwards.
#     redeployment = sha1(jsonencode([
#       aws_api_gateway_resource.example.id,
#       aws_api_gateway_method.example.id,
#       aws_api_gateway_integration.example.id,
#     ]))
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_api_gateway_stage" "example" {
#   deployment_id = aws_api_gateway_deployment.example.id
#   rest_api_id   = aws_api_gateway_rest_api.example.id
#   stage_name    = "example"
# }