module "alb" {
  source  = "./Modules/ALB"
  name    = var.name
  subnets = var.subnets
  vpc_id  = var.vpc_id
}

module "ASG" {
  source            = "./Modules/ASG"
  target_group_arns = [module.alb.asg_alb_tg_arn]
  vpc_id             = var.vpc_id
}
