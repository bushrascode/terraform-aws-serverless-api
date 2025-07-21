
data "archive_file" "nodejs_zip" {
  type        = "zip"
  source_file = "index.js"
  output_path = "index.zip"
}
// please allow Lambda service to assume this role 
data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  statement {
    actions    = ["sts:AssumeRole"]
    effect     = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
// iam role for the lambda function 
resource "aws_iam_role" "iam_role" {
  name               = "iam_role"
  assume_role_policy = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
}
// policy grants permissions that are necessary for the Lambda function to run
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// allows api gateway to invoke the lambda function 
resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "lambda_function"
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*/*"
}


resource "aws_lambda_function" "lambda_function" {
  filename         = data.archive_file.nodejs_zip.output_path
  function_name    = "lambda_function"
  role             = aws_iam_role.iam_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.nodejs_zip.output_base64sha256

  runtime = "nodejs20.x"

}


