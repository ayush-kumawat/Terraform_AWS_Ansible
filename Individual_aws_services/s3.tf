provider "aws" {
  region = "ap-south-1"
  access_key = "MY_ACCESS_KEY"
  secret_key = "MY_SECRET_KEY"
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
