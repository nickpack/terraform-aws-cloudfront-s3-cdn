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

output "cdn_subdomain" {
  value = var.cdn_subdomain
}

output "domain_name" {
  value = var.domain_name
}

output "cdn_fqdn" {
  value = local.cdn_fqdn
}

output "cdn_bucket_arn" {
  value = aws_s3_bucket.cdn_bucket.arn
}

output "ssl_cert_arn" {
  value = aws_acm_certificate.ssl_certificate.arn
}

output "cdn_bucket_regional_domain_name" {
  value = aws_s3_bucket.cdn_bucket.bucket_regional_domain_name
}

output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.cdn_distribution.arn
}
