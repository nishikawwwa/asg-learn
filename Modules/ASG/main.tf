resource "aws_launch_configuration" "asg-launch-configuration" {
  name          = "asg-launch-configuraion"
  image_id      = "ami-0ce107ae7af2e92b5"
  instance_type = "t3.micro"
  spot_price    = "0.0136"
  security_groups = [
    "sg-53a75422",
    aws_security_group.asg_security_group_for_ec2_instance.id
  ]

  user_data = <<-EOF
    #! /bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install nginx1 -y
    sudo touch /etc/nginx/conf.d/healthcheck.conf
    echo "server {
        listen 80 default_server;
        listen [::]:80 default_server;
        root /usr/share/nginx/html;

        location = /healthcheck {
            empty_gif;
            access_log off;
            break;
        }
    }" >> /etc/nginx/conf.d/healthcheck.conf
    sudo systemctl start nginx
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg-scaling-group" {
  name                      = "asg-group"
  min_size                  = 1
  max_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "ELB"
  launch_configuration      = aws_launch_configuration.asg-launch-configuration.id
  availability_zones        = data.aws_availability_zones.all.names
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  target_group_arns = var.target_group_arns

  tag {
    key                 = "Name"
    value               = "asg-ec2-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "asg-scaling-policy" {
  name                   = "asg-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.asg-scaling-group.name
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "PercentChangeInCapacity"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}

resource "aws_security_group" "asg_security_group_for_ec2_instance" {
  name        = "ec2-instance-sg"
  description = "sg for ec2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = ""
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = ""
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
