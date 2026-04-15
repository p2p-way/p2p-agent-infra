# CloudFront distribution - Control center
resource "aws_cloudfront_distribution" "cc" {
  count = local.create ? 1 : 0

  # General
  price_class = "PriceClass_All"
  web_acl_id  = try(aws_wafv2_web_acl.cc[count.index].arn, null)

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  http_version        = "http2and3"
  is_ipv6_enabled     = true
  comment             = local.description
  enabled             = true
  default_root_object = aws_s3_object.cc[count.index].key

  # Origins
  origin {
    domain_name              = aws_s3_bucket.cc[count.index].bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cc[count.index].id
    origin_id                = "s3-bucket"
  }

  # Behaviors
  default_cache_behavior {
    target_origin_id = "s3-bucket"
    compress         = true

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]

    cached_methods  = ["GET", "HEAD"]
    cache_policy_id = aws_cloudfront_cache_policy.cc[count.index].id

    # We can't remove policy dynamically - let's keep it all the time
    # https://github.com/hashicorp/terraform-provider-aws/issues/21730
    response_headers_policy_id = aws_cloudfront_response_headers_policy.cc[count.index].id

    dynamic "function_association" {
      for_each = var.cc_uri ? [] : [1]

      content {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.cc[count.index].arn
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.cc_uri ? [1] : []

    content {
      target_origin_id = "s3-bucket"
      compress         = true

      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD"]

      path_pattern    = "/${random_id.cc_uri[count.index].hex}"
      cached_methods  = ["GET", "HEAD"]
      cache_policy_id = aws_cloudfront_cache_policy.cc[count.index].id

      function_association {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.cc[count.index].arn
      }
    }
  }
}

# CloudFront cache policy - Control center
resource "aws_cloudfront_cache_policy" "cc" {
  count = local.create ? 1 : 0

  name        = local.policy_name
  comment     = local.description
  min_ttl     = 86400
  default_ttl = 86400
  max_ttl     = 86400

  parameters_in_cache_key_and_forwarded_to_origin {
    headers_config {
      header_behavior = "none"
    }

    cookies_config {
      cookie_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

# CloudFront response headers policy - Control center
resource "aws_cloudfront_response_headers_policy" "cc" {
  count = local.create ? 1 : 0

  name    = local.policy_name
  comment = local.description

  custom_headers_config {
    dynamic "items" {
      for_each = tomap({ server = "CloudFront" })

      content {
        header   = items.key
        override = true
        value    = items.value
      }
    }
  }

  remove_headers_config {
    dynamic "items" {
      for_each = ["x-amz-bucket-region", "content-type"]

      content {
        header = items.value
      }
    }
  }
}

# ClouFront Functions - Control center
resource "aws_cloudfront_function" "cc" {
  count = local.create ? 1 : 0

  name    = local.function_name
  runtime = "cloudfront-js-2.0"
  comment = local.description
  publish = true
  code    = templatefile("${path.module}/files/cloudfront.js", { cc = local.cc_commands })

  lifecycle {
    create_before_destroy = true
  }
}

# CloudFront Origin Access Control - Control center
resource "aws_cloudfront_origin_access_control" "cc" {
  count = local.create ? 1 : 0

  name                              = local.name
  description                       = local.description
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
