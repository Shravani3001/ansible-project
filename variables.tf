variable "region" {
    default = "us-east-1"
}

variable "instance_type" {
    default = "t2.micro"
}

variable "key_name" {
    default = "ansible-key"
}

variable "public_key_path" {
    default = "./ansible-key.pub"
}

variable "az1" {
    default = "us-east-1a"
}