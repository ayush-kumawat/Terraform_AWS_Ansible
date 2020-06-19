provider "aws" {
  region = "ap-south-1"
  access_key = "MY_ACCESS_KEY"
  secret_key = "MY_SECERET_KEY"
}
resource "aws_s3_bucket" "b" {
  bucket = "bucktfayushkumawat"
  acl = "public-read"
  tags = {
    Name = "bucktf"
    Environment = "prod" 
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = "bucktfayushkumawat"
  key    = "new_object_key"
  acl = "public-read"
  source = "/root/Desktop/imagenew5.png"
  content_type = "image/png"
  depends_on = [aws_s3_bucket.b]
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled = true
  origin {
    domain_name = aws_s3_bucket.b.bucket_regional_domain_name
    origin_id = aws_s3_bucket.b.id
    custom_origin_config {
      http_port = 80
      https_port = 80
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols = ["TLSv1" , "TLSv1.1" , "TLSv1.2"]
    }
  }
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.b.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
