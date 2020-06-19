provider "aws" {
  region = "ap-south-1"
  access_key = "MY_ACCESS_KEY"
  secret_key = "MY_SECRET_KEY"

}
resource "tls_private_key" "example" {
  algorithm   = "RSA"
}
resource "aws_key_pair" "deployer" {
  depends_on = [tls_private_key.example]
  key_name   = "deployer-key"
  public_key = "${tls_private_key.example.public_key_openssh}"
}
resource "local_file" "save_private" {
  depends_on = [aws_key_pair.deployer]
  content = "${tls_private_key.example.public_key_pem}"
  filename = "tera.pem"
  provisioner "local-exec" {
    command = "chmod 400 tera.pem "
  }
}

