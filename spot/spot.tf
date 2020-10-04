resource "aws_spot_instance_request" "cheap_worker" {
  count         = length(var.apps)
  ami           = data.aws_ami.ami.id
  spot_price    = "0.005"
  instance_type = "t3.micro"
}

resource "null_resource" "cli" {
  depends_on = [aws_security_group.aa,aws_spot_instance_request.cheap_worker]
  count = length(var.apps)
  provisioner "local-exec" {
    command = <<EOF
aws ec2 create-tags --resources ${element(aws_spot_instance_request.cheap_worker.*.spot_instance_id, count.index)} --tags Key=Name,Value=${element(var.apps, count.index)} --region us-east-2
aws ec2 modify-instance-attribute --instance-id ${element(aws_spot_instance_request.cheap_worker.*.spot_instance_id, count.index)} --groups ${aws_security_group.aa.id} --region us-east-2
EOF
  }

  provisioner "remote-exec" {
    connection {
      host = element(aws_spot_instance_request.cheap_worker.*.public_ip, count.index)
      user = "root"
      password = "DevOps321"
    }
    inline = [
      "disable-auto-shutdown",
      "set-hostname ${element(var.apps, count.index)}",
      "cd /home/centos",
      "git clone https://DevOps-Batches@dev.azure.com/DevOps-Batches/DevOps51/_git/shell-scripting",
      "chown centos:centos shell-scripting -R"
    ]
  }
}


data "aws_ami" "ami" {
  most_recent      = true
  name_regex       = "^Centos*"
  owners           = ["973714476881"]
}

provider "aws" {
  region = "us-east-2"
}

variable "apps" {
  default = ["frontend", "catalogue", "cart", "user", "shipping", "payment", "mongodb", "mysql", "rabbitmq", "redis"]
}

resource "aws_security_group" "aa" {
  name        = "aa"
  description = "aa"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aa"
  }
}

resource "aws_route53_record" "records" {
  count                       = length(var.apps)
  name                        = element(var.apps, count.index)
  type                        = "A"
  zone_id                     = "Z1003640306U1OCC0UY3J" // Update this as per your domain
  ttl                         = 300
  records                     = [element(aws_spot_instance_request.cheap_worker.*.private_ip, count.index)]
}