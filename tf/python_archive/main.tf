# Variables

variable "source_dir" {
  type = string
}

variable "archive_name" {
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
  output_path = "${var.archive_name}.${var.type}"
  excludes    = setunion(
    [for pattern in var.exclude_patterns : fileset(var.source_dir, pattern)]
  )
}

data "archive_file" "code_archive" {
  type        = var.type
  source_dir  = var.source_dir
  output_path = local.output_path
  excludes    = local.excludes
}

# Output

output output_path {
  value = local.output_path
}

output excludes {
  value = local.excludes
}

output file {
  value = data.archive_file.code_archive
}
