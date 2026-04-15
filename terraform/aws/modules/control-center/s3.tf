# Bucket - Control center
resource "aws_s3_bucket" "cc" {
  count = local.create ? 1 : 0

  bucket = local.name
  region = local.region
}

# Bucket object - Control center
resource "aws_s3_object" "cc" {
  count = local.create ? 1 : 0

  bucket  = aws_s3_bucket.cc[count.index].id
  key     = "index.html"
  content = ""
  region  = local.region
}

# Bucket policy - Control center
resource "aws_s3_bucket_policy" "cc" {
  count = local.create ? 1 : 0

  bucket = aws_s3_bucket.cc[count.index].id
  policy = data.aws_iam_policy_document.cc[count.index].json
  region = local.region
}

# Policy - Control center
data "aws_iam_policy_document" "cc" {
  count = local.create ? 1 : 0

  statement {
    principals {
      type = "Service"
      identifiers = [
        "cloudfront.amazonaws.com"
      ]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.cc[count.index].arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        aws_cloudfront_distribution.cc[count.index].arn
      ]
    }
  }
}
