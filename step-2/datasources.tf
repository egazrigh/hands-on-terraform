#
# TODO: Ecrire une datasource de type aws_vpc pour récupérer le vpc créé au step-1
# Hints:
#   https://www.terraform.io/docs/providers/aws/d/vpc.html
#

data "terraform_remote_state" "step1" {
  backend = "local"

  config {
    path = "${path.module}/../step-1/terraform.tfstate"
  }
}

data "aws_vpc" "devoxx_vpc" {
  id = "${data.terraform_remote_state.step1.vpc_id}"
}

data "aws_subnet_ids" "devoxx_subnets" {
  vpc_id = "${data.aws_vpc.devoxx_vpc.id}"
}

data "aws_subnet" "devoxx_subnet_details" {
  count = "${length(data.aws_subnet_ids.devoxx_subnets.ids)}"
  id    = "${data.aws_subnet_ids.devoxx_subnets.ids[count.index]}"
}
