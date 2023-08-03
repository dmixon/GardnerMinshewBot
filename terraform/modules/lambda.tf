data "aws_s3_bucket_object" "gardner_zip" {
  bucket = aws_s3_bucket.gardner_bucket.id
  key    = "gardnerminshewbot.zip"
}

resource "aws_lambda_function" "gardner_lambda" {
  s3_bucket         = var.bucket_name
  s3_key            = data.aws_s3_bucket_object.gardner_zip.key
  s3_object_version = data.aws_s3_bucket_object.gardner_zip.version_id
  function_name     = "GardnerMinshewBot"
  description       = "Will send a random gardner gif to Discord every day at 9 AM EST"
  role              = aws_iam_role.gardner_lambda.arn
  handler           = "gardnerminshewbot.lambda_handler"
  runtime           = "python3.10"
  timeout           = "30"
}
