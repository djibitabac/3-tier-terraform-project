resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-main_vpc"
  })
} 

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-igw"
  })
}

#  Creating two public subnets--------------------------
resource "aws_subnet" "public_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id

  cidr_block = var.public_subnet_cidr_block[0]

  availability_zone = var.availability_zone[0]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public_subnet_az_1a"
  })
}

resource "aws_subnet" "public_subnet_az_1c" {
  vpc_id     = aws_vpc.main_vpc.id

  cidr_block = var.public_subnet_cidr_block[1]

  availability_zone = var.availability_zone[1]

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public_subnet_az_1c"
  })
}

#  Creating two private subnets--------------------------
resource "aws_subnet" "private_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id

  cidr_block = var.private_subnet_cidr_block[0]

  availability_zone = var.availability_zone[0]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_subnet_az_1a"
  })
}

resource "aws_subnet" "private_subnet_az_1c" {
  vpc_id     = aws_vpc.main_vpc.id

  cidr_block = var.private_subnet_cidr_block[1]

  availability_zone = var.availability_zone[1]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_subnet_az_1c"
  })
}
#  Creating two db subnets--------------------------
resource "aws_subnet" "db_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id

  cidr_block = var.db_subnet_cidr_block[0]

  availability_zone = var.availability_zone[0]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db_subnet_az_1a"
  })
}

resource "aws_subnet" "db_subnet_az_1c" {
  vpc_id     = aws_vpc.main_vpc.id

  cidr_block = var.db_subnet_cidr_block[1]

  availability_zone = var.availability_zone[1]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db_subnet_az_1c"
  })
}

#  Creating public route table--------------------------
resource "aws_route_table" "apci_jupiter_public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-rt"
  })
}
#  Creating route table association--------------------------
resource "aws_route_table_association" "public_subnet_az_1a" {
  subnet_id      = aws_subnet.public_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}

resource "aws_route_table_association" "public_subnet_az_1c" {
  subnet_id      = aws_subnet.public_subnet_az_1c.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}

# Creating elastic IP for az 1a nat gateway------------------------------------------------
resource "aws_eip" "eip_az_1a" {
  domain   = "vpc"
  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip_az_1a"
  })
}

# Creating NAT gateway az 1a---------------------------------------------------
resource "aws_nat_gateway" "apci_jupiter_nat_gw_az_1a" {
  allocation_id = aws_eip.eip_az_1a.id
  subnet_id     = aws_subnet.public_subnet_az_1a.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat_gw_az_1a"
  })

  depends_on = [aws_eip.eip_az_1a, aws_subnet.public_subnet_az_1a]
}

# Creating Private route table for az 1a---------------------------------------------------
resource "aws_route_table" "apci_jupiter_private_rt_az_1a" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.apci_jupiter_nat_gw_az_1a.id
  }
tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_rt_az_1a"
  })
}

# Creating private route table association for az 1b-------------------------
resource "aws_route_table_association" "private_subnet_az_1a" {
  subnet_id      = aws_subnet.private_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1a.id
}

resource "aws_route_table_association" "db_subnet_az_1a" {
  subnet_id      = aws_subnet.db_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1a.id
}

# Creating elastic IP for az 1c nat gateway------------------------------------------------
resource "aws_eip" "eip_az_1c" {
  domain   = "vpc"
  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip_az_1c"
  })
}

# Creating NAT gateway az 1c---------------------------------------------------
resource "aws_nat_gateway" "apci_jupiter_nat_gw_az_1c" {
  allocation_id = aws_eip.eip_az_1c.id
  subnet_id     = aws_subnet.public_subnet_az_1c.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat_gw_az_1c"
  })

  depends_on = [aws_eip.eip_az_1c, aws_subnet.public_subnet_az_1c]
}

# Creating Private route table for az 1c---------------------------------------------------
resource "aws_route_table" "apci_jupiter_private_rt_az_1c" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.apci_jupiter_nat_gw_az_1c.id
  }
tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_rt_az_1c"
  })
}

# Creating private route table association for az 1c-------------------------
resource "aws_route_table_association" "private_subnet_az_1c" {
  subnet_id      = aws_subnet.private_subnet_az_1c.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1c.id
}

resource "aws_route_table_association" "db_subnet_az_1c" {
  subnet_id      = aws_subnet.db_subnet_az_1c.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1c.id
}
