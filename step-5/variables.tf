variable "name" {
  type        = "string"
  description = "Unique name"
}

variable "instance_type" {
  type        = "string"
  description = "EC2 instance type"
}

/*
variable "instance_ami" {
  type        = "string"
  description = "EC2 ami"
}
*/
variable "public_key_path" {
  type        = "string"
  description = "Public Key for SSH connexion"
}
