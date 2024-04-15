resource "aws_ecr_repository" "my_hello_flask_repo" {
  name                 = "my-hello-flask-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

output "repository_url" {
  value = aws_ecr_repository.my_hello_flask_repo.repository_url
}