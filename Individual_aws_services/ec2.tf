provider "aws" {
  region = "ap-south-1"
  access_key = "MY_ACCESS_KEY"
  secret_key = "MY_SECRET_KEY"
}

variable "enter_key" {
  type = string
  default = "ayush_kay"
}

resource "aws_instance" "first" {
  ami = "ami-005956c5f0f757d37"
  key_name = var.enter_key
  instance_type = "t2.micro"
  security_groups = [ "launch-wizard-3" ]
  tags = {
    Name = "terra"
  }
}

  
