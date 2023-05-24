variable "aws_region" {
type = string
default = "us-east-1"
}

variable "instance_size" {
type = string
default = "t2.medium"
}

variable "pub_ssh_key" {
type = string
default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDttlPdTIG5+yllaxSTayJZmLDzo35sxRrhA+5uGZP6x/5RGt/vtfSkWgyHkCCBYMa9T/s3T7QDkYHEGi5ob2r2qkEXjhnY+P/OUHZ38gR5B5uAbvQ+yqL1qb0mfBl+TdjCU/5GrN5PjpJvHY1F6P7wNyQMH/+437xz+Xdlt4uKvc4ED4fJISwwDmmmONQQZQ6uljD2PAq5FotJnle6b3a4KP/laM6VI66ELZTqFcjMw7/orviEvHNlFjgeLHTU5bmHJHo2GDb6U7D47N1Dby3flT8rFvPbZ4N2A+1F1eW6FGD5bYcaTcSDD5oldlOo4lrAVpknV9qm9cyMiNN3Zla1"
}

variable "ssh_key_name" {
type = string
default = "mb_keys"
}