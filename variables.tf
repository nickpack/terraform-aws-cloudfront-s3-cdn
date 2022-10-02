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

variable "region" {
  description = "AWS Region to deploy into"
  type        = string
  default     = "eu-west-1"
}

variable "domain_name" {
  description = "Domain name for your hosted route53 zone"
  type        = string
}

variable "cloudfront_price_class" {
  description = "CloudFront Price Class, Defaults to PriceClass_100"
  type        = string
  default     = "PriceClass_100"
}

variable "cdn_subdomain" {
  description = "The subdomain for your CDN"
  type        = string
  default     = "cdn"
}

variable "cors_origins" {
  description = "CORS origins, CDN subdomain is automatically added, additional TLDs configured here"
  type        = list(string)
  default     = []
}

variable "cors_allowed_methods" {
  description = "CORS allowed methods, Defaults to GET and POST"
  type        = list(string)
  default     = ["GET", "POST"]
}

variable "cors_allowed_headers" {
  description = "CORS allowed headers, Defaults to Authorization and Content-Length"
  type        = list(string)
  default     = ["Authorization", "Content-Length"]
}

variable "cors_expose_headers" {
  description = "CORS headers to expose, Defaults to ETag"
  type        = list(string)
  default     = ["ETag"]
}

variable "cors_max_age_seconds" {
  description = "CORS max age in seconds, Defaults to 3600"
  type        = number
  default     = 3600
}

variable "source_files_path" {
  description = "Path to the files for uploading to your CDN"
  type        = string
  default     = "./files"
}

variable "enable_logging" {
  description = "If set to true, a logging bucket will be created and the CDN S3 bucket access logs will be written to it"
  type        = bool
  default     = true
}
