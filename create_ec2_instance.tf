provider "aws" {
  region = "ap-south-1"
}
resource "aws_instance" "myinstance" {
  ami                    = "ami-052cef05d01020f1d"
  name                   = "myinstance"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.keypair.id
  vpc_security_group_ids = [aws_security_group.allow_ports.id]
  user_data              = <<-EOF
             #!/bin/bash
              yum install httpd -y
              echo "hey i am $(hostname -f)" > /var/www/html/index.html
              service httpd start
              chkconfig httpd on
              EOF

  tags = {
    Name = "terra"
  }

}
resource "aws_key_pair" "keypair" {
  key_name   = "terraform1"
  public_key = file("./terraform1.pub")
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}
resource "aws_security_group" "allow_ports" {
  name        = "allow_ports"
  description = "Allow inbound traffic"
  vpc_id      = aws_default_vpc.default.id
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "tomcat port from VPC"
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
    Name = "allow_ports"
  }
}

resource "aws_eip" "myeip" {
  vpc      = true
  instance = aws_instance.myinstance.id
}

output "myeip" {
  value = aws_eip.myeip.public_ip
}
