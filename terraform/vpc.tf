resource "aws_vpc" "eadeploy-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name
  enable_classiclink   = "false"
  instance_tenancy     = "default"
  tags = {
    Name = "eadeploy-vpc"
  }
}

resource "aws_subnet" "ead-public" {
  count             = length(var.subnet_cidrs_public)
  vpc_id            = aws_vpc.eadeploy-vpc.id
  cidr_block        = var.subnet_cidrs_public[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "ead-public"
    Tier = "Public"
  }

}

resource "aws_subnet" "ead-private" {
  count             = length(var.subnet_cidrs_private)
  vpc_id            = aws_vpc.eadeploy-vpc.id
  cidr_block        = var.subnet_cidrs_private[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "ead-private"
    Tier = "Private"
  }

}

resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.eadeploy-vpc.id
  tags = {
    Name = "prod-igw"
  }
}

resource "aws_route_table" "eadesign-public-rt" {
  vpc_id = aws_vpc.eadeploy-vpc.id

  route {
    //associated subnet can reach everywhere
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-igw.id
  }

  tags = {
    Name = "prod-eadesign-rt"
  }
}

resource "aws_route_table" "eadesign-private-rt" {
  vpc_id = aws_vpc.eadeploy-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_GATEWAY.id
  }

  tags = {
    Name = "prod-eadesign-rt"
  }
}



# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "Nat-Gateway-EIP" {
  vpc = true
}

# Creating a NAT Gateway!
resource "aws_nat_gateway" "NAT_GATEWAY" {
  depends_on = [
    aws_eip.Nat-Gateway-EIP
  ]
  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.Nat-Gateway-EIP.allocation_id
  # Associating it in the Public Subnet!

  subnet_id = (aws_subnet.ead-public[1].id)
  tags = {
    Name = "EADeploy-NAT Gateway"
  }
}

resource "aws_route_table_association" "public-rt-association" {
  count          = length(var.subnet_cidrs_public)
  subnet_id      = element(aws_subnet.ead-public.*.id, count.index)
  route_table_id = aws_route_table.eadesign-public-rt.id
}

resource "aws_route_table_association" "private-rt-association" {
  count          = length(var.subnet_cidrs_public)
  subnet_id      = element(aws_subnet.ead-private.*.id, count.index)
  route_table_id = aws_route_table.eadesign-private-rt.id
}


data "aws_subnet_ids" "public" {
  vpc_id = aws_vpc.eadeploy-vpc.id

  tags = {
    Tier = "Public"
  }
}

data "aws_subnet" "public" {
  for_each = data.aws_subnet_ids.public.ids

  id         = each.value
  depends_on = [aws_subnet.ead-private]
}


data "aws_subnet_ids" "private" {
  vpc_id = aws_vpc.eadeploy-vpc.id

  tags = {
    Tier = "Private"
  }
}

data "aws_subnet" "private" {
  for_each = data.aws_subnet_ids.private.ids

  id         = each.value
  depends_on = [aws_subnet.ead-private]
}

