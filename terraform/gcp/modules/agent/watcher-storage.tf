# Bucket suffix - Watcher
resource "random_string" "watcher" {
  count = local.watcher_create ? 1 : 0

  length  = 10
  upper   = false
  special = false
}

# Bucket - Watcher
resource "google_storage_bucket" "watcher" {
  count = local.watcher_create ? 1 : 0

  name                     = "${local.watcher_name}-${random_string.watcher[count.index].result}"
  force_destroy            = true
  public_access_prevention = "enforced"

  location = local.region
}

# Archive - Watcher
data "archive_file" "watcher" {
  count = local.watcher_create ? 1 : 0

  type        = "zip"
  source_dir  = "${path.module}/files/${var.watcher_folder}"
  output_path = "${var.watcher_folder}-${local.region}.zip"
}

# Upload to Storage - Watcher
resource "google_storage_bucket_object" "watcher" {
  count = local.watcher_create ? 1 : 0

  bucket         = google_storage_bucket.watcher[count.index].name
  name           = data.archive_file.watcher[count.index].output_path
  source         = data.archive_file.watcher[count.index].output_path
  source_md5hash = filemd5(data.archive_file.watcher[count.index].output_path)
}
