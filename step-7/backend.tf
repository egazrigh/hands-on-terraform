#
# TODO: Créer une configuration de backend de type s3 qui enregistre vos tfstates dans le bucket créé
# en step-4.
#
#
terraform {
  backend "s3" {
    bucket = "eg2-s3bucket-for-hands-on-terraform"
    key    = "hands-on-terraform/terraform.tfstate"
    region = "eu-west-3"
  }
}
