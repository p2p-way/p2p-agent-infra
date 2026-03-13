# Bucket suffix - Watcher
resource "random_string" "watcher" {
  count = local.watcher_create ? 1 : 0

  length  = 10
  upper   = false
  special = false
}

# Bucket - Watcher
resource "aws_s3_bucket" "watcher" {
  count = local.watcher_create ? 1 : 0

  bucket        = "${local.watcher_name}-${random_string.watcher[count.index].result}"
  force_destroy = true

  region = local.region
}

# Archive - Watcher
data "archive_file" "watcher" {
  count = local.watcher_create ? 1 : 0

  type        = "zip"
  source_file = "${path.module}/files/${var.watcher_file}"
  output_path = "${var.watcher_file}-${local.region}.zip"
}

# Upload to S3 - Watcher
resource "aws_s3_object" "watcher" {
  count = local.watcher_create ? 1 : 0

  bucket      = aws_s3_bucket.watcher[count.index].id
  key         = "${var.watcher_file}-${local.region}.zip"
  source      = data.archive_file.watcher[count.index].output_path
  source_hash = filemd5(data.archive_file.watcher[count.index].output_path)

  region = local.region
}
