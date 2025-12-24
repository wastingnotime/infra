resource "aws_ecr_repository" "contacts-web" {
  name = "contacts-web"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "contacts-web_ecr_url" {
  value = aws_ecr_repository.contacts-web.repository_url
}

resource "aws_ecr_repository" "contacts-api" {
  name = "contacts-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "contacts-api_ecr_url" {
  value = aws_ecr_repository.contacts-api.repository_url
}