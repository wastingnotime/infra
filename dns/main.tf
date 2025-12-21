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

data "aws_route53_zone" "root" {
  name         = "wastingnotime.org"
  private_zone = false
}

resource "aws_route53_record" "root_a" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "wastingnotime.org"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "root_aaaa" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "wastingnotime.org"
  type    = "AAAA"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

data "terraform_remote_state" "swarm" {
  backend = "local"
  config = {
    path = "../swarm/terraform.tfstate"
  }
}

resource "aws_route53_record" "origin_a" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "origin.wastingnotime.org"
  type    = "A"
  ttl     = 60
  records = [data.terraform_remote_state.swarm.outputs.swarm_manager_eip]
}

