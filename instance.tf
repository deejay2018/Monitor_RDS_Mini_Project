
provider "aws" {
  region = "eu-west-1"
  profile = "default"
}

# toolbox instance
resource "aws_instance" "toolbox" {

  ami                         = "ami-0bb3fad3c0286ebd5"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.prometheus_key_pair.key_name
  subnet_id                   = aws_subnet.public-subnet-monitor.id
  #availability_zone           = data.aws_availability_zones.zones.names[0]
  vpc_security_group_ids      = [ aws_security_group.Monitor.id ]
  user_data                   = file("monitorsftr.sh")

  associate_public_ip_address = true

	root_block_device {
		volume_type = "gp2"
		delete_on_termination = true
	}

  tags = {
    Name = "Monitoring"
    Environment = "ToolBox"
  }
}

resource "aws_instance" "webserver-1" {

  depends_on = [
		aws_db_instance.mariaDB
  ]
  ami                         = "ami-0bb3fad3c0286ebd5"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.prometheus_key_pair.key_name
  subnet_id                   = aws_subnet.public-subnet-monitor.id
  #availability_zone           = data.aws_availability_zones.zones.names[0]
  vpc_security_group_ids      = [ aws_security_group.Monitor.id ]
  user_data                   = file("websftr.sh")
  associate_public_ip_address = true


	root_block_device {
		volume_type = "gp2"
		delete_on_termination = true
	}

  tags = {
    Name = "Webserver 1"
  }
}

resource "aws_instance" "webserver-2" {

  depends_on = [
		aws_db_instance.mariaDB
  ]
  ami                         = "ami-0bb3fad3c0286ebd5"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.prometheus_key_pair.key_name
  subnet_id                   = aws_subnet.public-subnet-webserver.id
  #availability_zone           = data.aws_availability_zones.zones.names[1]
  vpc_security_group_ids      = [ aws_security_group.web.id ]
  user_data                   = file("websftr.sh")
  associate_public_ip_address = true

	root_block_device {
		volume_type = "gp2"
		delete_on_termination = true
	}

  tags = {
    Name = "Webserver 2"
  }
}



resource "null_resource" "toolbox-provisioner" {

    triggers = {
    public_ip = aws_instance.toolbox.public_ip
  }
    connection {
    user          = "ec2-user"
    #host          = self.public_ip
    host          = aws_instance.toolbox.public_ip
    private_key   = tls_private_key.sshkeygen_execution.private_key_pem
    timeout       = "30"
  }

    # Copy the prometheus file to instance
  provisioner "file" {
    source      = "./compose"
    destination = "/tmp"
  }

    # Copy the prometheus file to instance
  provisioner "file" {
    source      = "./monitor"
    destination = "/tmp"
  }



# Install docker in the ubuntu
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install ansible2 -y",
      "sudo yum install -y docker",
      "sudo usermod -a -G docker ec2-user",
      "sudo service docker start",
      "sudo systemctl enable docker",
      "sudo cp /tmp/compose/* ~/",
      "sudo cp /tmp/monitor/* ~/",
      "sudo mkdir prometheus-data/",
      "sudo cp  /tmp/monitor/prometheus.yml   ~/prometheus-data/",
      "sudo mkdir  config/",
      "sudo cp  /tmp/monitor/blackbox.yml   ~/config/",
      "sudo sed -i 's;<access_key>;${aws_iam_access_key.prometheus_access_key.id};g' ~/prometheus-data/prometheus.yml",
      "sudo sed -i 's;<secret_key>;${aws_iam_access_key.prometheus_access_key.secret};g' ~/prometheus-data/prometheus.yml"
    ]
  }



  provisioner "local-exec" {
    command = "echo '${tls_private_key.sshkeygen_execution.private_key_pem}' >> ${aws_key_pair.prometheus_key_pair.id}.pem ; chmod 400 ${aws_key_pair.prometheus_key_pair.id}.pem"
  }

}

resource "null_resource" "web1-provisioner" {

    triggers = {
    public_ip = aws_instance.webserver-1.public_ip
  }
    connection {
    user          = "ec2-user"
    #host          = self.public_ip
    host          = aws_instance.webserver-1.public_ip
    private_key   = tls_private_key.sshkeygen_execution.private_key_pem

  }

  # Copy the  file to instance
  provisioner "file" {
    source      = "./nginx-inst"
    destination = "/tmp"
  }


  # Install docker in the instance
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo yum install mysql -y",
      "sudo usermod -a -G docker ec2-user",
      "sudo service docker start",
      "sudo systemctl enable docker",
      "sudo cp /tmp/docker-compose.yml ~/",
      "sudo cp /tmp/nginx-inst/* ~/"



    ]
  }


}

resource "null_resource" "web2-provisioner" {

    triggers = {
    public_ip = aws_instance.webserver-2.public_ip
  }
    connection {
    user          = "ec2-user"
    #host          = self.public_ip
    host          = aws_instance.webserver-2.public_ip
    private_key   = tls_private_key.sshkeygen_execution.private_key_pem

  }

  # Copy the  file to instance
  provisioner "file" {
    source      = "./nginx-inst"
    destination = "/tmp"
  }


  # Install docker in the instance
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo yum install mysql -y",
      "sudo usermod -a -G docker ec2-user",
      "sudo service docker start",
      "sudo systemctl enable docker",
      "sudo cp /tmp/docker-compose.yml ~/",
      "sudo cp /tmp/nginx-inst/* ~/"



    ]
  }


}





# Output of the ip
/*
output "Grafana_URL" {
  value = "http://${aws_instance.toolbox.public_ip}:3000"
}
*/

/*
output "Prometheus_URL" {
  value = "http://${aws_instance.prometheus_instance.public_ip}:9090"
}
*/



# Outputs.tf

output "toolbox" {
  value = aws_instance.toolbox.public_ip
}
output "Webserver1" {
  value = aws_instance.webserver-1.public_ip
}

output "Webserver2" {
  value = aws_instance.webserver-2.public_ip
}


