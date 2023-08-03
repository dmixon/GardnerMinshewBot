resource "aws_cloudwatch_event_rule" "gardner_daily" {
  name                = "daily"
  description         = "Fires at 9 AM - currently using ${var.savings_time_notation}"
  schedule_expression = "cron(0 ${var.hour} * * ? *)" #this is 9 AM, either in EST or EDT
}

resource "aws_cloudwatch_event_target" "gardner_target" {
  rule      = aws_cloudwatch_event_rule.gardner_daily.name
  target_id = "lambda"
  arn       = aws_lambda_function.gardner_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.gardner_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.gardner_daily.arn
}
