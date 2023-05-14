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
  type    = list(string)
  default = [
    "**/__pycache__/**",
  ]
}

# Content

locals {
  output_path          = "${var.name}.${var.type}"
  excludes_per_pattern = [for pattern in var.exclude_patterns : fileset(var.source_dir, pattern)]
  excludes             = flatten(local.excludes_per_pattern)
}

data "archive_file" "code_archive" {
  type        = var.type
  source_dir  = var.source_dir
  output_path = local.output_path
  excludes    = local.excludes
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
