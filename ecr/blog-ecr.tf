resource "aws_ecr_repository" "blog" {
  name = "blog"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "blog_ecr_url" {
  value = aws_ecr_repository.blog.repository_url
}
