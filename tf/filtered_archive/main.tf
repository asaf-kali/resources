# Variables

variable "source_dir" {
  type = string
}

variable "name" {
  type = string
}

variable "type" {
  type    = string
  default = "zip"
}

variable "exclude_patterns" {
  type = list(string)
  default = [
    "**/__pycache__/**",
  ]
}

variable "output_file_mode" {
  type    = string
  default = "0644"
}

# Content

locals {
  output_path          = "${var.name}.${var.type}"
  excludes_per_pattern = [for pattern in var.exclude_patterns : fileset(var.source_dir, pattern)]
  excludes = flatten(local.excludes_per_pattern)
}

data "archive_file" "code_archive" {
  type             = var.type
  source_dir       = var.source_dir
  output_path      = local.output_path
  output_file_mode = var.output_file_mode
  excludes         = local.excludes
}

# Outputs

output output_path {
  value = data.archive_file.code_archive.output_path
}

output excludes_per_pattern {
  value = local.excludes_per_pattern
}

output excludes {
  value = local.excludes
}

output file {
  value = data.archive_file.code_archive
}

output "output_sha" {
  value = data.archive_file.code_archive.output_base64sha256
}
