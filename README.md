# Terraform_AWS_Ansible
Integration of terraform, aws and ansible to design architecture for a web server.
==========================================================================================================================================
What we want to achieve:
1. Create the key and security group which allow the port 80 and 22.
2. Launch EC2 instance.
3. In this EC2 instance use the key and security group which we have created in step 1.
4. Launch one Volume (EBS) and mount on /var/www/html.
5. Developer will upload the code on github with some image data.
6. Deploy the web-server code on ec2 instance created above.
7. Create S3 bucket, and copy/deploy the images from github repo into the s3 bucket and change the permission to public readable.
8. Create a Cloudfront using s3 bucket(which contains images) and use the Cloudfront URL to update in code in /var/www/html.
Blog_link: https://medium.com/@ayush21kumawat/what-we-want-to-achieve-81787acebc7f
====================================================================================================================================================
provider "aws" {
  region = "ap-south-1"
  access_key = "MY_KEY"
  secret_key = "MY_SECRET_KEY"
}
resource "tls_private_key" "example" {
  algorithm   = "RSA"
  rsa_bits = 4096
}
resource "aws_key_pair" "deployer" {
  depends_on = [tls_private_key.example]
  key_name   = "tera"
  public_key = tls_private_key.example.public_key_openssh
}
resource "local_file" "save_private" {
  depends_on = [aws_key_pair.deployer]
  content = tls_private_key.example.private_key_pem
  filename = "tera.pem"
  provisioner "local-exec" {
    command = "chmod 400 tera.pem"
  }
}
=====================================================================================================================================================
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "myown"
  }
}
=====================================================================================================================================================
resource "aws_s3_bucket" "b" {
  depends_on = [local_file.save_private]
  bucket = "bucktfayushkumawat"
  acl = "public-read"
  tags = {
    Name = "bucktf"
    Environment = "prod"
  }
provisioner "local-exec" {
  command = "ansible-playbook s3_git.yml"
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = "bucktfayushkumawat"
  key    = "new_object_key"
  acl = "public-read"
  source = "/git/India.jpg"
  content_type = "image/jpg"
  depends_on = [aws_s3_bucket.b]
}
=====================================================================================================================================================
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
    target_origin_id = aws_s3_bucket.b.id

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
provisioner "local-exec" {
  command = "echo 'url: http://${aws_cloudfront_distribution.s3_distribution.domain_name}/${aws_s3_bucket_object.object.key}' > url.yml"
  }
}
=====================================================================================================================================================
resource "aws_instance" "first" {
  depends_on = [aws_key_pair.deployer]
  ami = "ami-005956c5f0f757d37"
  key_name = aws_key_pair.deployer.key_name
  instance_type = "t2.micro"
  security_groups = [ "${aws_security_group.allow_ssh.name}" ]
  tags = {
    Name = "terra"
  }
}
=====================================================================================================================================================
resource "aws_ebs_volume" "myebs" {
  availability_zone = aws_instance.first.availability_zone
  depends_on = [aws_instance.first]
  size              = 1

  tags = {
    Name = "myebs1"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  depends_on = [aws_ebs_volume.myebs]
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.myebs.id
  instance_id = aws_instance.first.id
  force_detach = true
}
=====================================================================================================================================================
resource "null_resource" "null1" {
  depends_on = [aws_volume_attachment.ebs_att]
  provisioner "local-exec" {
    command = "echo ${aws_instance.first.public_ip} ansible_ssh_private_key_file=/Teraform/Final_task1/tera.pem > /Teraform/Final_task1/inventory"
  }
  provisioner "local-exec" {
    command = "ansible-playbook Packages.yml"
  }
  provisioner "local-exec" {
    command = "ansible-playbook partition.yml"
  }
  provisioner "local-exec" {
    command = "ansible-playbook git.yml"
  }
}
=====================================================================================================================================================
