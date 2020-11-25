# === ALB ===
variable "name" {
  type    = string
  default = "asg-alb"
}

variable "subnets" {
  type = list(string)
  default = [
    "subnet-ce4fb286",
    "subnet-b98ca3e2",
    "subnet-1a975031"
  ]
}

variable "instance_ids" {
  type    = list(string)
  default = [""]
}

# === Security Group ===
variable "vpc_id" {
  type    = string
  default = "vpc-471f2c20"
}
