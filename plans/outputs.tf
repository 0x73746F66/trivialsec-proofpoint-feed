output "feed_processor_proofpoint_arn" {
    value = aws_lambda_function.feed_processor_proofpoint.arn
}
output "feed_processor_proofpoint_role" {
  value = aws_iam_role.feed_processor_proofpoint_role.name
}
output "feed_processor_proofpoint_role_arn" {
  value = aws_iam_role.feed_processor_proofpoint_role.arn
}
output "feed_processor_proofpoint_policy_arn" {
  value = aws_iam_policy.feed_processor_proofpoint_policy.arn
}
