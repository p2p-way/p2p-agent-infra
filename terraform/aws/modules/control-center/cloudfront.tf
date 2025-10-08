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

  http_version    = "http2and3"
  is_ipv6_enabled = true
  comment         = local.description
  enabled         = true

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

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.cc[count.index].arn
    }
  }

  # Error pages
  dynamic "custom_error_response" {
    for_each = [400, 403, 404, 405, 414, 416, 500, 501, 502, 503, 504]
    content {
      error_code            = custom_error_response.value
      error_caching_min_ttl = 600
      response_code         = 200
      response_page_path    = "/"
    }
  }
}

# CloudFront cache policy - Control center
resource "aws_cloudfront_cache_policy" "cc" {
  count = local.create ? 1 : 0

  name        = local.policy_name
  comment     = local.description
  min_ttl     = 0
  default_ttl = 0
  max_ttl     = 0

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
