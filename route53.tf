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

resource "aws_route53_record" "cdn-a" {
  zone_id = data.aws_route53_zone.dns_zone.zone_id
  name    = local.cdn_fqdn
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cdn_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for validation_options in aws_acm_certificate.ssl_certificate.domain_validation_options : validation_options.domain_name => {
      name    = validation_options.resource_record_name
      record  = validation_options.resource_record_value
      type    = validation_options.resource_record_type
      zone_id = data.aws_route53_zone.dns_zone.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}
