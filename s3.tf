/*
  Copyright 2022 Nick Pack

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

resource "aws_s3_bucket" "cdn_bucket" {
  bucket = local.cdn_fqdn
}

resource "aws_s3_bucket_policy" "allow_cloudfront_origin_access" {
  bucket = aws_s3_bucket.cdn_bucket.id
  policy = data.aws_iam_policy_document.allow_cloudfront_origin_access.json
}

resource "aws_s3_bucket_acl" "cdn_bucket_acl" {
  bucket = aws_s3_bucket.cdn_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "cdn_bucket_website" {
  bucket = aws_s3_bucket.cdn_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "cdn_bucket_cors" {
  bucket = aws_s3_bucket.cdn_bucket.id

  cors_rule {
    allowed_headers = var.cors_allowed_headers
    allowed_methods = var.cors_allowed_methods
    allowed_origins = concat(["https://${local.cdn_fqdn}"], var.cors_origins)
    expose_headers  = var.cors_expose_headers
    max_age_seconds = var.cors_max_age_seconds
  }
}

resource "aws_s3_bucket_public_access_block" "cdn_bucket_public_block" {
  bucket                  = aws_s3_bucket.cdn_bucket.id
  ignore_public_acls      = true
  block_public_acls       = true
  restrict_public_buckets = true
  block_public_policy     = true
}

resource "aws_s3_bucket" "cdn_log_bucket" {
  count  = var.enable_logging ? 1 : 0
  bucket = "${local.cdn_fqdn}-logs"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_acl" "cdn_log_bucket_acl" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.cdn_log_bucket[0].id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cdn_log_bucket_encryption" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.cdn_log_bucket[0].bucket
  /* @todo Use KMS */
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_logging" "cdn_bucket_logging" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.cdn_bucket.id

  target_bucket = aws_s3_bucket.cdn_log_bucket[0].id
  target_prefix = "s3/"
}

resource "aws_s3_bucket_public_access_block" "cdn_log_bucket_public_block" {
  count                   = var.enable_logging ? 1 : 0
  bucket                  = aws_s3_bucket.cdn_log_bucket[0].id
  ignore_public_acls      = true
  block_public_acls       = true
  restrict_public_buckets = true
  block_public_policy     = true
}
