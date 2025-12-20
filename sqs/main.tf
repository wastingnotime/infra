terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.80.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_sqs_queue" "this" {
  name                      = var.queue_name
  sqs_managed_sse_enabled   = true

  # Match existing AWS config (import-safe)
  max_message_size = 1048576
}

resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__owner_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::590183855481:root"
      },
      "Action": "SQS:*",
      "Resource": "arn:aws:sqs:us-east-1:590183855481:wnt-plausible-events"
    }
  ]
}
POLICY
}

# Import existing resources:
# terraform import aws_sqs_queue.this https://sqs.us-east-1.amazonaws.com/590183855481/wnt-plausible-events
# terraform import aws_sqs_queue_policy.this https://sqs.us-east-1.amazonaws.com/590183855481/wnt-plausible-events
