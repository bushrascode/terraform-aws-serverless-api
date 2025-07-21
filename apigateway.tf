// the actual api 
resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "my_api_gateway"
  description = "my api gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
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
  http_method             = aws_api_gateway_method.method_request.http_method
  resource_id             = aws_api_gateway_resource.root_path.id
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
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
  depends_on  = [aws_api_gateway_method.method_request, aws_api_gateway_integration.integration_request]
}

// options to avoid dealing with cors error 

// when a user hits /mypath i want it to handle both a POST req (earlier) and a OPTIONS req (below)
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.root_path.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

// when someone sends an OPTIONS request, just respond with a 200 OK. No need to talk to a backend
resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.root_path.id
  http_method             = aws_api_gateway_method.options_method.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

// when you respond to this OPTIONS request, I need you to include these specific headers in the response
resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.root_path.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  // needed for cors 
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

}

// actually sets the values for the CORS headers you declared in the previous block
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.root_path.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  // needed for cors
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [
    aws_api_gateway_method.options_method,
    aws_api_gateway_integration.options_integration,
  ]
}
// Okay, I’ve defined everything for this API. Now let’s actually deploy it so it works!
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  depends_on  = [aws_api_gateway_integration.integration_request, aws_api_gateway_integration.options_integration]
}