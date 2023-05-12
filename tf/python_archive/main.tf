# Variables

variable "path" {
  type = string
}

variable "archive_name" {
  type = string
}

# Content

locals {
  output_path = "${var.archive_name}.zip"
  excludes    = setunion(
    fileset(var.path, "**/__pycache__/**"),
    fileset(var.path, "**/*.pyc"),
  )
}

data "archive_file" "code_archive" {
  type        = "zip"
  source_dir  = var.path
  output_path = local.output_path
  excludes    = local.excludes
}

# Output

output output_path {
  value = local.output_path
}

output "excludes" {
  value = local.excludes
}

output "archive_file" {
  value = data.archive_file.code_archive
}
