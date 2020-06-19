provider "aws" {
  region = "ap-south-1"
  profile = "Ghost"
}
resource "aws_ebs_volume" "myebs" {
  availability_zone = aws_instance.first.availability_zone
  depends_on = [aws_instance.first]
  size              = 1

  tags = {
    Name = "myebs1"
  }
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
resource "aws_volume_attachment" "ebs_att" {
  depends_on = [aws_ebs_volume.myebs]
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.myebs.id}"
  instance_id = "${aws_instance.first.id}"
  force_detach = true
}






