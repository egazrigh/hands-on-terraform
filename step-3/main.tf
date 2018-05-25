#
# TODO: Créer une ressource de type 'aws_lb' nommée 'first' et liée à tous les subnets de notre datasource aws_subnet
# et dans le security_group de votre datasource 'step2'
#
# Hints:
#   https://www.terraform.io/docs/providers/aws/r/lb.html
#

resource "aws_lb" "first" {
  subnets         = ["${data.aws_subnet_ids.devoxx_subnets.ids}"]
  security_groups = ["${data.terraform_remote_state.step2.security_group_id}"]
}

resource "aws_lb_target_group" "first_tg" {
  name     = "devoxx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.devoxx_vpc.id}"
}

resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = "${aws_lb_target_group.first_tg.arn}"
  target_id        = "${data.terraform_remote_state.step2.instance_id}"
  port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.first.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.first_tg.arn}"
    type             = "forward"
  }
}

#
# TODO: Créer une instance ec2 en piochant certaines valeurs d'attribut dans variables.tf
# Le security_group doit être le même que celui créé en step-2.
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

resource "aws_instance" "my_instance2" {
  #ami = "${var.instance_ami}"
  ami                    = "${data.aws_ami.latest_centos_ami.id}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${data.terraform_remote_state.step2.security_group_id}"]
  subnet_id              = "${element(data.aws_subnet.devoxx_subnet_details.*.id,0)}" # enfin !

  #key_name = "${aws_key_pair.keypair.key_name}"

  tags {
    Name    = "${var.name}"
    Env     = "Test"
    Billing = "Someone Else"
  }
  user_data = <<EOF
  #cloud-config
  runcmd:
    - yum install -y httpd
    - echo "Instance " >> /var/www/html/index.html 
    - curl http://169.254.169.254/latest/meta-data/instance-id >> /var/www/html/index.html
    - echo " created by Terraform" >> /var/www/html/index.html 
    - systemctl start httpd
    - systemctl enable httpd
  EOF
}

#
# TODO: Attacher l'instance créée au target_group 'first_tg'
#
# Hints:
#   https://www.terraform.io/docs/providers/aws/r/lb_target_group_attachment.html
#

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = "${aws_lb_target_group.first_tg.arn}"
  target_id        = "${aws_instance.my_instance2.id}"
  port             = 80
}
