variable "account_id" {
  type = string
}

resource "aws_iam_role" "github_actions_ecr" {
  name = "github-actions-ecr"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${var.account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            # Restrict to ONE repo initially for max security
            "token.actions.githubusercontent.com:sub" = "repo:wastingnotime/blog:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_actions_ecr_policy" {
  role = aws_iam_role.github_actions_ecr.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        Resource = "*"
      }
    ]
  })
}

output "github_actions_ecr_role_arn" {
  value = aws_iam_role.github_actions_ecr.arn
}
