
data "archive_file" "nodejs_zip" {
  type        = "zip"
  source_file = "index.js"
  output_path = "index.zip"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "lambda_function" {
  filename         = data.archive_file.nodejs_zip.output_path
  function_name    = "lambda_function"
  role             = aws_iam_role.example.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.nodejs_zip.output_base64sha256

  runtime = "nodejs20.x"

}


