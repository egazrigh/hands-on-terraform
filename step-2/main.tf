resource "aws_key_pair" "keypair" {
  key_name   = "devoxx-keypair"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.aws_vpc.devoxx_vpc.id}"

  tags = {
    Name = "${var.name}"
  }
}

#
# TODO: Ecrire une ressource de type aws_security_group_rule, liée au security_group nommé allow_all
# Elle doit être de type ingress et autoriser tous les ports, tous les protocoles, et toutes les ip d'origine en entrée
# Hints:
#   https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
#
resource "aws_security_group_rule" "allow_in" {
  type              = "ingress"
  security_group_id = "${aws_security_group.allow_all.id}"
  from_port         = "-1"
  to_port           = "-1"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

#
# TODO: Ecrire une ressource de type aws_security_group_rule, liée au security_group nommé allow_all
# Elle doit être de type egress et autoriser tous les ports, tous les protocoles, et toutes les ip de destination
# Hints:
#   https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
#

resource "aws_security_group_rule" "allow_out" {
  type              = "egress"
  security_group_id = "${aws_security_group.allow_all.id}"
  from_port         = "-1"
  to_port           = "-1"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

#
# TODO: Créer une instance ec2 en piochant certaines valeurs d'attribut dans variables.tf
# Le security_group doit être celui pour lequel ous avez créé des règles.
# Le script de démarrage doit être le suivant :
#
#  user_data = <<EOF
#  #cloud-config
#  runcmd:
#    - yum install -y httpd
#    - curl http://169.254.169.254/latest/meta-data/instance-id > /var/www/html/index.html
#    - systemctl start httpd
#    - systemctl enable httpd
#  EOF
#

resource "aws_instance" "my_instance" {
  ami = "${var.instance_ami}"

  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]

  #subnet_id              = "subnet-0f35091ec04ddf776"
  #subnet_id = "${data.aws_vpc.devoxx_vpc.id}" #Donne le bon vpc mais pas le subnet id
  subnet_id = "${element(data.aws_subnet_ids.devoxx_subnets.ids,0)}" # fonctionne mais sans utiliser devoxx_subnet_details

  key_name = "${aws_key_pair.keypair.key_name}"

  tags {
    Name    = "${var.name}"
    Env     = "Test"
    Billing = "Someone Else"
  }

  user_data = <<EOF
  #cloud-config
  runcmd:
    - yum install -y httpd
    - curl http://169.254.169.254/latest/meta-data/instance-id > /var/www/html/index.html
    - systemctl start httpd
    - systemctl enable httpd
  EOF
}
