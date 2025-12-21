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
  alias  = "use1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "this" {
    certificate_authority_arn = null
    domain_name               = "wastingnotime.org"
    early_renewal_duration    = null
    key_algorithm             = "RSA_2048"
    region                    = "us-east-1"
    subject_alternative_names = [
        "wastingnotime.org",
    ]
    tags                      = {}
    tags_all                  = {}
    validation_method         = "DNS"

    options {
        certificate_transparency_logging_preference = "ENABLED"
        export                                      = "DISABLED"
    }
}