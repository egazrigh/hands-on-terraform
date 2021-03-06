data "aws_vpc" "devoxx_vpc" {
  cidr_block = "10.10.0.0/16"
}

data "aws_subnet_ids" "devoxx_subnets" {
  vpc_id = "${data.aws_vpc.devoxx_vpc.id}"
}

data "aws_subnet" "devoxx_subnet_details" {
  count = "${length(data.aws_subnet_ids.devoxx_subnets.ids)}"
  id    = "${data.aws_subnet_ids.devoxx_subnets.ids[count.index]}"
}

data "aws_ami" "latest_centos_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*CentOS Linux 7 x86_64 HVM EBS*"]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    name = "${var.name}"
  }
}
