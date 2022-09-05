resource "aws_vpc" "myvpc" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}


# create avaiabilty zones
data "aws_availability_zones" "available" {
  state = "available"
}
# creating public subnet
resource "aws_subnet" "public-sub" {
    count = length(data.aws_availability_zones.available.names)

  vpc_id     = aws_vpc.myvpc.id
  cidr_block = element(var.public-cidr,count.index)
  map_public_ip_on_launch ="true"
  availability_zone = element(data.aws_availability_zones.available.names,count.index)

  tags = {
    Name = "public subnet-${count.index+1}"
  }
}
 #creating private subnet
resource "aws_subnet" "private-sub" {
    count = length(data.aws_availability_zones.available.names)

  vpc_id     = aws_vpc.myvpc.id
  cidr_block = element(var.private-cidr,count.index)
  #map_public_ip_on_launch ="true"
  availability_zone = element(data.aws_availability_zones.available.names,count.index)

  tags = {
    Name = "private subnet-${count.index+1}"
  }
}
 #creating data subnet
resource "aws_subnet" "data-sub" {
    count = length(data.aws_availability_zones.available.names)

  vpc_id     = aws_vpc.myvpc.id
  cidr_block = element(var.data-cidr,count.index)
  #map_public_ip_on_launch ="true"
  availability_zone = element(data.aws_availability_zones.available.names,count.index)

  tags = {
    Name = "data subnet-${count.index+1}"
  }
}
#crating igw
resource "aws_internet_gateway" "internet-get" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}

#nat getway crating
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-sub[0].id

  tags = {
    Name = "gw NAT"
  }
}

#crating EIP 
resource "aws_eip" "eip" {
  vpc      = true
}

#creting public rout table
resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-get.id
  }

  tags = {
    Name = "public-route"
  }
}
#creting private rout table
resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
   nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "private-route"
  }
}
#crating public subnet association
resource "aws_route_table_association" "public" {
    count= length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.public-sub[*].id,count.index)
  route_table_id = aws_route_table.public-route.id
}
#crating private subnet association
resource "aws_route_table_association" "private" {
    count=length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.private-sub[*].id,count.index)
  route_table_id = aws_route_table.private-route.id
}
#crating data subnet association
resource "aws_route_table_association" "data" {
    count=length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.data-sub[*].id,count.index)
  route_table_id = aws_route_table.private-route.id
}