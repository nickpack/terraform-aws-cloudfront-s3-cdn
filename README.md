# CloudFront & S3 CDN/static site with Terraform

A terraform module to quickly provision an S3 & Cloudfront powered CDN and populate the bucket with files from a local directory (File state is managed by terraform).

There are plenty of examples of similar things on the internet, some good, some bad, a lot are outdated and using deprecated aws provider features, or ask far more questions than I want to answer.

This is relatively opinionated, asking only for things that you're likely to want to configure rather than giving you 10000000 settings.

## What this module will provision

* An S3 Bucket with a CORS policy and private only access to hold your static files
* An CloudFront OAI policy for allowing CloudFront access to your bucket objects (get only)
* An TLS certificate with ACM, using DNS validation
* A CloudFront distribution with some sensible defaults
* Route53 records for your CDN FQDN and for DNS validation for the TLS cert
* Files from a local path uploaded to your S3 bucket (If you change/add/delete files in the directory you can terraform apply again and the local state will be reflected in the bucket)

### Optionally (Enabled by default)

* S3 and CloudFront access logging
* An S3 bucket for cloudfront/s3 access logging encrypted at rest

## Prerequisites

* The module expects that the hosted zone for your domain_name setting is already configured in Route53 - it does not attempt to provision it

## What this module doesn't do

* Encryption at rest for the CDN files bucket - they are publicly served so this is probably a little overkill
* Create your hosted zone in Route53
* Destroy your logging bucket - if you enable logging a bucket will be created but is explicitly prevented from being destroyed so that you don't accidently lose all of your access logs
* Replication - this isn't difficult, but I haven't needed it
* Versioning - this is really easy to implement, but I haven't needed it

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.33.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.33.0 |
| <a name="provider_aws.acm_provider"></a> [aws.acm\_provider](#provider\_aws.acm\_provider) | 4.33.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_template_files"></a> [template\_files](#module\_template\_files) | hashicorp/dir/template | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.ssl_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.cdn_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.cdn_origin_access_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_route53_record.cdn-a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.cdn_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.cdn_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.cdn_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.cdn_log_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.cdn_bucket_cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_logging.cdn_bucket_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.allow_cloudfront_origin_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.cdn_bucket_public_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.cdn_log_bucket_public_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cdn_log_bucket_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_website_configuration.cdn_bucket_website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_s3_object.static_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_iam_policy_document.allow_cloudfront_origin_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.dns_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cdn_subdomain"></a> [cdn\_subdomain](#input\_cdn\_subdomain) | The subdomain for your CDN | `string` | `"cdn"` | no |
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | CloudFront Price Class, Defaults to PriceClass\_100 | `string` | `"PriceClass_100"` | no |
| <a name="input_cors_allowed_headers"></a> [cors\_allowed\_headers](#input\_cors\_allowed\_headers) | CORS allowed headers, Defaults to Authorization and Content-Length | `list(string)` | <pre>[<br>  "Authorization",<br>  "Content-Length"<br>]</pre> | no |
| <a name="input_cors_allowed_methods"></a> [cors\_allowed\_methods](#input\_cors\_allowed\_methods) | CORS allowed methods, Defaults to GET and POST | `list(string)` | <pre>[<br>  "GET",<br>  "POST"<br>]</pre> | no |
| <a name="input_cors_expose_headers"></a> [cors\_expose\_headers](#input\_cors\_expose\_headers) | CORS headers to expose, Defaults to ETag | `list(string)` | <pre>[<br>  "ETag"<br>]</pre> | no |
| <a name="input_cors_max_age_seconds"></a> [cors\_max\_age\_seconds](#input\_cors\_max\_age\_seconds) | CORS max age in seconds, Defaults to 3600 | `number` | `3600` | no |
| <a name="input_cors_origins"></a> [cors\_origins](#input\_cors\_origins) | CORS origins, CDN subdomain is automatically added, additional TLDs configured here | `list(string)` | `[]` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name for your hosted route53 zone | `string` | n/a | yes |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | If set to true, a logging bucket will be created and the CDN S3 bucket access logs will be written to it | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to deploy into | `string` | `"eu-west-1"` | no |
| <a name="input_source_files_path"></a> [source\_files\_path](#input\_source\_files\_path) | Path to the files for uploading to your CDN | `string` | `"./files"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cdn_bucket_arn"></a> [cdn\_bucket\_arn](#output\_cdn\_bucket\_arn) | n/a |
| <a name="output_cdn_bucket_regional_domain_name"></a> [cdn\_bucket\_regional\_domain\_name](#output\_cdn\_bucket\_regional\_domain\_name) | n/a |
| <a name="output_cdn_fqdn"></a> [cdn\_fqdn](#output\_cdn\_fqdn) | n/a |
| <a name="output_cdn_subdomain"></a> [cdn\_subdomain](#output\_cdn\_subdomain) | n/a |
| <a name="output_cloudfront_distribution_arn"></a> [cloudfront\_distribution\_arn](#output\_cloudfront\_distribution\_arn) | n/a |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | n/a |
| <a name="output_ssl_cert_arn"></a> [ssl\_cert\_arn](#output\_ssl\_cert\_arn) | n/a |
<!-- END_TF_DOCS -->

## What could do with improving

* Encryption at rest is currently done using AES256 - in this day and age I should probably have done this with a KMS key - I'll probably look at this later

## License

Licensed under the Apache License, Version 2.0 (the "License");

## Author

Nick Pack <https://github.com/nickpack>
