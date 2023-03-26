resource "aws_lambda_function" "feed_processor_proofpoint" {
  filename      = "${abspath(path.module)}/${local.source_file}"
  source_code_hash = filebase64sha256("${abspath(path.module)}/${local.source_file}")
  function_name = local.function_name
  role          = aws_iam_role.feed_processor_proofpoint_role.arn
  handler       = "app.handler"
  runtime       = local.python_version
  timeout       = local.timeout
  memory_size   = local.memory_size
  layers        = var.app_env == "Prod" ? ["arn:aws:lambda:ap-southeast-2:725887861453:layer:Dynatrace_OneAgent_1_261_5_20230309-143152_python:1"] : []

  environment {
    variables = {
      APP_ENV = var.app_env
      APP_NAME = var.app_name
      LOG_LEVEL = var.log_level
      STORE_BUCKET = "${data.terraform_remote_state.trivialscan_s3.outputs.trivialscan_store_bucket[0]}"
      BUILD_ENV = var.build_env
      AWS_LAMBDA_EXEC_WRAPPER = "/opt/dynatrace" # Use the wrapper from the layer
      DT_TENANT = var.app_env == "Prod" ? "xuf85063" : ""
      DT_CLUSTER_ID = var.app_env == "Prod" ? "-1273248646" : ""
      DT_CONNECTION_BASE_URL = "https://xuf85063.live.dynatrace.com"
      DT_CONNECTION_AUTH_TOKEN = var.app_env == "Prod" ? var.dynatrace_token : ""
      DT_OPEN_TELEMETRY_ENABLE_INTEGRATION = "true"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_iam_role_policy_attachment.policy_attach
  ]
  tags = local.tags
}

resource "aws_cloudwatch_event_rule" "feed_processor_proofpoint_schedule" {
    name = "${lower(var.app_env)}_feed_processor_proofpoint_schedule"
    description = "Schedule for Lambda Function"
    schedule_expression = var.schedule
}

resource "aws_cloudwatch_event_target" "schedule_lambda" {
    rule = aws_cloudwatch_event_rule.feed_processor_proofpoint_schedule.name
    target_id = "${lower(var.app_env)}_feed_processor_proofpoint"
    arn = aws_lambda_function.feed_processor_proofpoint.arn
}

resource "aws_lambda_permission" "allow_events_bridge_to_run_lambda" {
    statement_id = "${var.app_env}AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.feed_processor_proofpoint.function_name
    principal = "events.amazonaws.com"
}

resource "aws_cloudwatch_log_group" "proofpoint_logs" {
  skip_destroy      = var.app_env == "Prod"
  name              = "/aws/lambda/${aws_lambda_function.feed_processor_proofpoint.function_name}"
  retention_in_days = local.retention_in_days
}
