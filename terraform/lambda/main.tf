
# Data block to zip .py file
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "index.js"
  output_path = "index.zip"
}

# Lambda function to deploy Python Hello World website
resource "aws_lambda_function" "hello_world" {
  filename         = "index.zip"
  function_name    = format("lambda-%s-%s-%s", var.app_name, var.env, var.region)
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# IAM role giving permission to use Lambda service
resource "aws_iam_role" "iam_for_lambda" {
  name = format("lambda-iam-role-%s-%s", var.app_name, var.env)

  assume_role_policy = jsonencode(
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
   ]
 })
}

# resource "aws_iam_role_policy_attachment" "lambda_basic" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
#   role       = aws_iam_role.iam_for_lambda.name
# }

# resource "aws_lambda_permission" "apigw_lambda" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.hello_world.function_name
#   principal     = "apigateway.amazonaws.com"

#   source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
# }
