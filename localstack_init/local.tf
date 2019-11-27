provider "aws" {
  access_key                  = "mock_access_key"
  region                      = "eu-west-1"
  s3_force_path_style         = true
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    lambda  = "http://localhost:4574"
    s3      = "http://localhost:4572"
    sqs     = "http://localhost:4576"
  }
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = "${var.ib_bucket_name}"
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "output-bucket"
}

resource "aws_lambda_function" "transferOrdsPoster_lambda" {
  function_name = "transferOrdsPoster"
  filename      = "../lambda_s3_copy.zip"
  role          = "r1"
  handler       = "lambda_s3_copy.handler"
  runtime       = "python3.6"
    environment {
    variables = {
            STAGE = "LOCAL"
    }
  }
}

resource "aws_sqs_queue" "local_queue" {
  name = "local-queue"

  tags = {
    Environment = "localstack"
  }
}

resource "aws_lambda_event_source_mapping" "sqstrigger" {
  event_source_arn = "${aws_sqs_queue.local_queue.arn}"
  function_name    = "${aws_lambda_function.transferOrdsPoster_lambda.arn}"
}

resource "aws_s3_bucket_notification" "notification_nextail_lambdas" {
  bucket = "${aws_s3_bucket.data_bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.transferOrdsPoster_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
    // filter_prefix       = ""
  }
}

// resource "aws_lambda_permission" "allow_bucket" {
//   statement_id  = "AllowExecutionFromS3Bucket"
//   action        = "lambda:InvokeFunction"
//   function_name = "${aws_lambda_function.transferOrdsPoster_lambda.arn}"
//   principal     = "s3.amazonaws.com"
//   source_arn    = "${aws_s3_bucket.data_bucket.arn}"
// }