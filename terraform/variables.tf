variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "container_image" {
  description = "The Docker image to use in the ECS container"
  type        = string
  default     = "227173486361.dkr.ecr.us-east-1.amazonaws.com/my-hello-flask-repo"
}


variable "image_tag" {
  description = "The tag for the Docker image"
  type        = string
  default     = "latest"
}