resource "aws_ecr_repository" "space_repository" {
  name = "colbydehart/space"
}

resource "aws_ecr_lifecycle_policy" "space_policy" {
  repository = aws_ecr_repository.space_repository.name

  policy = <<EOF
  {
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
  }
  EOF
}
