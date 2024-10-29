# Variables

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.18"
    }
  }
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "ecr_name" {
  type        = string
  description = "ECR repository name"
}

variable "ecr_url" {
  type        = string
  description = "ECR repository URL"
}

variable "name" {
  type        = string
  description = "Name of the image"
}

variable "build_dir" {
  type        = string
  description = "Path to the build directory"
  default     = "."
}

variable "docker_file" {
  type        = string
  description = "Path to the Dockerfile"
}

variable "src_image" {
  type        = string
  description = "Source image for the build"
  default     = ""
}

variable "src_tag" {
  type        = string
  description = "Source image tag for the build"
  default     = "latest"
}

variable "dst_tag" {
  type        = string
  description = "Tag of the built image"
  default     = "latest"
}

variable "triggers" {
  type = map(string)
  description = "Triggers for the image build"
}

locals {
  dst_tag = "${var.name}-${var.dst_tag}"
}

# Resources

resource "null_resource" "image_build" {
  triggers = var.triggers

  provisioner "local-exec" {
    command = <<EOF
           aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
           docker build -t ${var.ecr_url}:${local.dst_tag} ${var.build_dir} -f ${var.docker_file} --build-arg SRC_IMAGE=${var.src_image} --build-arg SRC_TAG=${var.src_tag}
           docker push ${var.ecr_url}:${local.dst_tag}
       EOF
  }
}

data "aws_ecr_image" "image" {
  repository_name = var.ecr_name
  image_tag       = local.dst_tag
  depends_on = [
    null_resource.image_build
  ]
}

# Outputs

output "id" {
  value = data.aws_ecr_image.image.id
}

output "tag" {
  value = data.aws_ecr_image.image.image_tag
}
