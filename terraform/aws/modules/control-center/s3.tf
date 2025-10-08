# Bucket - Control center
resource "aws_s3_bucket" "cc" {
  count = local.create ? 1 : 0

  bucket = local.name
}
