output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
  description = "The ARN Of The s3 Bucket"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform-locks.name
  description = "The name of the DynamoDB table."
}