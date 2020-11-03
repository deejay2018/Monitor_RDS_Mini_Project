
# -- Creating Security Groups for public

resource "aws_security_group" "Monitor" {
	name        = "Monitor-sg"
  	description = "Allow TLS inbound traffic"
  	vpc_id      = aws_vpc.MainVPC.id


  	ingress {
    		description = "SSH"
    		from_port   = 22
    		to_port     = 22
    		protocol    = "tcp"
    		cidr_blocks = [ "0.0.0.0/0" ]
  	}

	ingress {
    		description = "web"
    		from_port   = 80
    		to_port     = 80
    		protocol    = "tcp"
    		cidr_blocks = [ "0.0.0.0/0" ]
  	}


  	ingress {
    		description = "public-port1"
    		from_port   = 3000
    		to_port     = 3000
    		protocol    = "tcp"
    		cidr_blocks = [ "0.0.0.0/0" ]
  	}

	ingress {
    		description = "public-port2"
    		from_port   = 9090
    		to_port     = 9090
    		protocol    = "tcp"
    		cidr_blocks = [ "0.0.0.0/0" ]
  	}


	ingress {
			description = "public-port3"
			from_port   = 9093
			to_port     = 9093
			protocol    = "tcp"
			cidr_blocks = [ "0.0.0.0/0" ]
}

	ingress {
    		description = "SSH"
    		from_port   = 9100
    		to_port     = 9100
    		protocol    = "tcp"
    		cidr_blocks = [ "0.0.0.0/0" ]
  	}

	ingress {
			description = "public-port4"
			from_port   = 9115
			to_port     = 9115
			protocol    = "tcp"
			cidr_blocks = [ "0.0.0.0/0" ]
}


	ingress {
			description = "public-port5"
			from_port   = 9300
			to_port     = 9300
			protocol    = "tcp"
			cidr_blocks = [ "0.0.0.0/0" ]
}


  	egress {
    		from_port   = 0
    		to_port     = 0
    		protocol    = "-1"
    		cidr_blocks = ["0.0.0.0/0"]
  	}

  	tags = {
    		Name = "Monitoring"
  	}
}
resource "aws_security_group" "web" {
	name        = "webserver-sg"
  	description = "Allow TLS inbound traffic"
  	vpc_id      = aws_vpc.MainVPC.id


  	ingress {
    		description = "SSH"
    		from_port   = 22
    		to_port     = 22
    		protocol    = "tcp"
    		cidr_blocks = [ "0.0.0.0/0" ]
  	}


  	ingress {
    		description = "SSH"
    		from_port   = 9100
    		to_port     = 9100
    		protocol    = "tcp"
    		cidr_blocks = [ "0.0.0.0/0" ]
  	}


  	ingress {
    		description = "public-port"
    		from_port   = 80
    		to_port     = 80
    		protocol    = "tcp"
    		cidr_blocks = [ "0.0.0.0/0" ]
  	}

  	egress {
    		from_port   = 0
    		to_port     = 0
    		protocol    = "-1"
    		cidr_blocks = ["0.0.0.0/0"]
  	}

  	tags = {
    		Name = "Monitoring"
  	}
}



# -- Creating Security Groups for private

resource "aws_security_group" "db" {
	depends_on = [
		aws_security_group.web,
  	]
	name        = "database-sg"
  	description = "Disallow TLS inbound traffic"
  	vpc_id      = aws_vpc.MainVPC.id



  	ingress {
    		description = "private-port"
    		from_port   = 3306
    		to_port     = 3306
    		protocol    = "tcp"
    		security_groups = [ aws_security_group.web.id ]
  	}

	  	ingress {
    		description = "SSH"
    		from_port   = 22
    		to_port     = 22
    		protocol    = "tcp"
    		cidr_blocks = [ "0.0.0.0/0" ]
			security_groups = [ aws_security_group.web.id ]

  	}


  	egress {
    		from_port   = 0
    		to_port     = 0
    		protocol    = "-1"
    		cidr_blocks = ["0.0.0.0/0"]
  	}

  	tags = {
    		Name = "private-sg"
        	}
}

