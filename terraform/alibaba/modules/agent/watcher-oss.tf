# Bucket suffix - Watcher
resource "random_string" "watcher" {
  count = local.watcher_create ? 1 : 0

  length  = 10
  upper   = false
  special = false
}

# Bucket - Watcher
resource "alicloud_oss_bucket" "watcher" {
  count = local.watcher_create ? 1 : 0

  bucket        = "${local.watcher_name}-${random_string.watcher[count.index].result}"
  force_destroy = true
}

# Upload to OSS - Watcher
resource "alicloud_oss_bucket_object" "watcher" {
  count = local.watcher_create ? 1 : 0

  bucket = alicloud_oss_bucket.watcher[count.index].id
  key    = "watcher-layer-${var.watcher_runtime}.zip"
  source = "${path.root}/watcher-python-layer.zip"
}
