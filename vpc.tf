# -- Creating vpc

resource "aws_vpc" "MainVPC" {
	cidr_block       = "10.9.0.0/16"
	instance_tenancy = "default"
	enable_dns_hostnames = "true"

	tags = {
  		Name = "Main-vpc"
  	}
}

# -- Creating internet-gateway

resource "aws_internet_gateway" "monitor-igw" {
	vpc_id = aws_vpc.MainVPC.id

	tags = {
  		Name = "Monitor-igw"
  	}
}



# -- Creating subnet

data "aws_availability_zones" "zones" {
	state = "available"
}

# -- Creating public subnet

resource "aws_subnet" "public-subnet-monitor" {
	availability_zone = data.aws_availability_zones.zones.names[0]
	cidr_block = "10.9.1.0/24"
	vpc_id = aws_vpc.MainVPC.id
	map_public_ip_on_launch = "true"

	tags = {
		Name = "public-subnet-monitor"
	}
}
resource "aws_subnet" "public-subnet-webserver" {
	availability_zone = data.aws_availability_zones.zones.names[1]
	cidr_block = "10.9.2.0/24"
	vpc_id = aws_vpc.MainVPC.id
	map_public_ip_on_launch = "true"

	tags = {
		Name = "public-subnet-web1"
	}
}



# -- Creating private subnet 1
resource "aws_subnet" "private-subnet-rds-1" {
	availability_zone = data.aws_availability_zones.zones.names[2]
	cidr_block = "10.9.4.0/24"
	vpc_id = aws_vpc.MainVPC.id

	tags = {
		Name = "private-subnet-1b"
	}
}

# -- Creating private subnet 2
resource "aws_subnet" "private-subnet-rds-2" {
	availability_zone = data.aws_availability_zones.zones.names[1]
	cidr_block = "10.9.5.0/24"
	vpc_id = aws_vpc.MainVPC.id

	tags = {
		Name = "private-subnet-1b"
	}
}



# -- Create route table for public
resource "aws_route_table" "route-public" {
	vpc_id = aws_vpc.MainVPC.id

	route {
  		cidr_block = "0.0.0.0/0"
  		gateway_id = aws_internet_gateway.monitor-igw.id
  	}

	tags = {
    		Name = "pg-route-igw"
  	}
}


# -- Subnet Association for public

resource "aws_route_table_association" "subnet-monitor-asso" {
		subnet_id      = aws_subnet.public-subnet-monitor.id
  		route_table_id = aws_route_table.route-public.id
}
resource "aws_route_table_association" "subnet-web1-asso" {
		subnet_id      = aws_subnet.public-subnet-webserver.id
  		route_table_id = aws_route_table.route-public.id
}



# -- Create route table for private
resource "aws_route_table" "route_private" {
  vpc_id = aws_vpc.MainVPC.id

  tags = {
    Name = "private-route-table"
  }
}

# -- Subnet Association for private
resource "aws_route_table_association" "private_1" {
  subnet_id      	= aws_subnet.private-subnet-rds-1.id
  route_table_id 	= aws_route_table.route_private.id
}
resource "aws_route_table_association" "private_2" {
  subnet_id      	= aws_subnet.private-subnet-rds-2.id
  route_table_id 	= aws_route_table.route_private.id
}