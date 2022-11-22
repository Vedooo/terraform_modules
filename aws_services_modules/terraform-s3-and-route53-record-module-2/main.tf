terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}


resource "aws_s3_bucket" "devops-bucket" {
  bucket = var.bucket-name
}

resource "aws_s3_bucket_website_configuration" "bucket-website" {
  bucket = aws_s3_bucket.devops-bucket.bucket
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.devops-bucket.id
  policy = templatefile("s3-policy.json", { bucket = var.bucket-name })
}

resource "aws_s3_object" "bucket-object" {
  bucket = var.bucket-name
  key = "index.html"
  source = "../src/index.html"
  acl = "public-read"
}

resource "aws_route53_zone" "bucket-domain" {
  name = var.domain-name
}

resource "aws_route53_record" "domain-record" {
  zone_id = aws_route53_zone.bucket-domain.zone_id
  name = var.domain-name
  type = "A"
  alias {
    name = aws_s3_bucket.devops-bucket.website_endpoint
    zone_id = aws_s3_bucket.devops-bucket.hosted_zone_id
    evaluate_target_health = true
  }
}