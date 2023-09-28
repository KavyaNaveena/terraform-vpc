resource "aws_vpc" "main" {
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"

  tags = {
    Name = "vpc-automated"
  }
}

resource "aws_subnet" "public" {
   vpc_id = aws_vpc.main.id
   cidr_block = "10.0.1.0/24"

   tags = {
      Name = "public-subnet-automated"
   }
}

resource "aws_subnet" "private" {
   vpc_id = aws_vpc.main.id
   cidr_block = "10.0.2.0/24"

   tags = {
      Name = "private-subnet-automated"
   }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-automated"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt-automated"
  }
}

resource "aws_eip" "eip-automated" {
  
}

resource "aws_nat_gateway" "natgw" {
   allocation_id = aws_eip.eip-automated.id
   subnet_id     = aws_subnet.public.id

  tags = {
    Name = "natgw-automated"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "private-rt-automated"
  }
}

resource "aws_route_table_association" "publicassociation" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "privateassociation" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private-rt.id
}