
variable "vpc_id" {
  type = string
}
variable "image_id" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "key_name" {
  type = string
}
variable "public_subnet_az_1a" {
  type = string
}
variable "tags" {
  type = map(string)
}
variable "private_subnet_az_1a" {
  type = string
}
variable "private_subnet_az_1c" {
  type = string
}