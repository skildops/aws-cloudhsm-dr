data "archive_file" "backup" {
  type        = "zip"
  source_file = "${path.module}/../src/backup.py"
  output_path = "${path.module}/backup.zip"
}
