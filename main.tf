provider "aws" {
  region = "us-east-1"
}



data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet_ids" "this" {
  vpc_id = var.vpc_id
}



#Create an instance
resource "aws_instance" "this" {
  ami           = "ami-0323c3dd2da7fb37d"
  instance_type = "t2.micro"
  key_name      = "yreddy"
  vpc_security_group_ids = ["${aws_security_group.this.id}"]
  user_data =  data.template_file.script.rendered
  tags = {
    Name = "dev-jenkins-ec2"
  }
}

#Create security group
resource "aws_security_group" "this" {
    name = "dev-jenkins-sg"
    description = "Jenkins sg"
    vpc_id      = "vpc-9eafc6fb"

}

#ingress
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["74.103.168.197/32"]
  security_group_id = aws_security_group.this.id
}

#ingress
resource "aws_security_group_rule" "allow_efs_on_2049" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  source_security_group_id       = aws_security_group.this.id
  security_group_id = aws_security_group.this.id
}

#ingress
resource "aws_security_group_rule" "allow_8080" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id       = aws_security_group.this.id
  security_group_id = aws_security_group.this.id
}


#egress rule
resource "aws_security_group_rule" "egress_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.this.id
  cidr_blocks = ["0.0.0.0/0"]
}


#Create EFS file system
resource "aws_efs_file_system" "this" {
  creation_token = "dev-jenkins"

  tags = {
    Name = "devjenkins"
  }
}



#mount EFS
resource "aws_efs_mount_target" "this" {
  for_each  =   data.aws_subnet_ids.this.ids
  file_system_id = aws_efs_file_system.this.id
  subnet_id      = each.value
  security_groups = ["${aws_security_group.this.id}"]
}


data "template_file" "script" {
  template = "${file("userdata.tpl")}"
  vars = {
    efs_id = "${aws_efs_file_system.this.id}"
  }
}