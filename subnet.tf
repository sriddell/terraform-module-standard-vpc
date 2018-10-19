resource "aws_subnet" "public" {
  count = "${length(split(",", var.az))}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${element(split(",", var.az), count.index)}"
  cidr_block =  "${element(split(",", var.pub_subnet_cidr), count.index)}"
  tags {
    Name = "${var.service}-public_subnet-${count.index}"
    CostCenter = "${var.costcenter}"
    Environment = "${var.environment}"
    Service = "${var.service}"
    POC = "${var.poc}"
    Group = "${var.group}"
  }
}

output "public_subnets" {
    value  = "${aws_subnet.public.*.id}"
}

resource "aws_route_table" "route" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.service}-main_route_table"
    CostCenter = "${var.costcenter}"
    Environment = "${var.environment}"
    Service = "${var.service}"
    POC = "${var.poc}"
    Group = "${var.group}"
  }
}

resource "aws_route" "igw" {
    route_table_id = "${aws_route_table.route.id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
    depends_on = ["aws_route_table.route"]
}

resource "aws_route_table_association" "public" {
  count = "${length(split(",", var.az))}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.route.id}"
}


resource "aws_subnet" "private" {
  count = "${length(split(",", var.az))}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${element(split(",", var.az), count.index)}"
  cidr_block =  "${element(split(",", var.priv_subnet_cidr), count.index)}"
  tags {
    Name = "${var.service}-private_subnet-${count.index}"
    CostCenter = "${var.costcenter}"
    Environment = "${var.environment}"
    Service = "${var.service}"
    Group = "${var.group}"
  }
}

output "private_subnets" {
    value = "${aws_subnet.private.*.id}"
}

resource "aws_eip" "nateip" {
    count = "${length(split(",", var.az))}"
    vpc = true
}

output "nat_ips" {
    value = "${aws_eip.nateip.*.public_ip}"
}

resource "aws_nat_gateway" "natgateway" {
  count = "${length(split(",", var.az))}"
  allocation_id = "${element(aws_eip.nateip.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  depends_on = ["aws_eip.nateip"]
}


resource "aws_route_table" "priv_rt" {
  count = "${length(split(",", var.az))}"
  depends_on = ["aws_nat_gateway.natgateway"]
  vpc_id = "${aws_vpc.vpc.id}"
  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = "${element(aws_nat_gateway.natgateway.*.id, count.index)}"
  }
  tags {
    Name = "${var.service}-private"
    CostCenter = "${var.costcenter}"
    Environment = "${var.environment}"
    Service = "${var.service}"
    POC = "${var.poc}"
    Group = "${var.group}"
  }
}

resource "aws_route_table_association" "private" {
  count = "${length(split(",", var.az))}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.priv_rt.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "private-s3" {
    count = "${length(split(",", var.az))}"
    vpc_endpoint_id = "${aws_vpc_endpoint.private-s3.id}"
    route_table_id = "${element(aws_route_table.priv_rt.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "public-s3" {
    vpc_endpoint_id = "${aws_vpc_endpoint.private-s3.id}"
    route_table_id = "${aws_route_table.route.id}"
}

