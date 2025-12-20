terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Import first, then replace the placeholder blocks with the
# exact values from `terraform state show` so the plan converges.
resource "aws_cloudfront_distribution" "this" {
  aliases = [
    "wastingnotime.org",
  ]
  enabled = true
  is_ipv6_enabled                 = true
  tags = {
    "Name" = "gh-pages-origin"
  }
  tags_all = {
    "Name" = "gh-pages-origin"
  }
  web_acl_id = "arn:aws:wafv2:us-east-1:590183855481:global/webacl/CreatedByCloudFront-b558745c/7b91d317-8074-4cd0-8185-6da14c99092b"

  origin {
    connection_attempts         = 3
    connection_timeout          = 10
    domain_name                 = "origin.wastingnotime.org"
    origin_access_control_id    = null
    origin_id                   = "plausible-api"
    origin_path                 = null
    response_completion_timeout = 0

    custom_header {
      name  = "X-Plausible-Token"
      value = "520761a9-6155-440e-87af-40af6427b739"
    }

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      ip_address_type          = "ipv4"
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "SSLv3",
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }
  origin {
    connection_attempts         = 3
    connection_timeout          = 10
    domain_name                 = "origin.wastingnotime.org"
    origin_access_control_id    = null
    origin_id                   = "blog"
    origin_path                 = null
    response_completion_timeout = 0

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      ip_address_type          = "ipv4"
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "SSLv3",
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }


  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cache_policy_id = "83da9c7e-98b4-4e11-a168-04f0df8e2c65"
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress                   = true
    default_ttl                = 0
    field_level_encryption_id  = null
    max_ttl                    = 0
    min_ttl                    = 0
    origin_request_policy_id   = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
    realtime_log_config_arn    = null
    response_headers_policy_id = null
    smooth_streaming           = false
    target_origin_id           = "blog"
    trusted_key_groups         = []
    trusted_signers            = []
    viewer_protocol_policy     = "allow-all"

    grpc_config {
      enabled = false
    }
  }

  ordered_cache_behavior {
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT",
    ]
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress                   = true
    default_ttl                = 0
    field_level_encryption_id  = null
    max_ttl                    = 0
    min_ttl                    = 0
    origin_request_policy_id   = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
    path_pattern               = "/api/event"
    realtime_log_config_arn    = null
    response_headers_policy_id = null
    smooth_streaming           = false
    target_origin_id           = "plausible-api"
    trusted_key_groups         = []
    trusted_signers            = []
    viewer_protocol_policy     = "redirect-to-https"

    function_association {
      event_type   = "viewer-request"
      function_arn = "arn:aws:cloudfront::590183855481:function/RewriteApiEventToEventsPlausible"
    }

    grpc_config {
      enabled = false
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:590183855481:certificate/ba9dd7ac-45dd-4be2-bd58-78f480af5871"
    cloudfront_default_certificate = false
    iam_certificate_id             = null
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}





