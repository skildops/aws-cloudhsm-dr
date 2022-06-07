data "template_file" "backup" {
  template = file("../src/backup.py")
}

data "archive_file" "backup" {
  type        = "zip"
  output_path = "${path.module}/backup.zip"
  source {
    content  = data.template_file.backup.rendered
    filename = "backup.py"
  }
}
