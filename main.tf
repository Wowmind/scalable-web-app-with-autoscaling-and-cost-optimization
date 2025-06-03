
// ec2_Autoscaling group
resource "aws_launch_template" "web" {
  name_prefix   = "web-lt-"
  image_id      = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
echo "Hello from $(hostname -f)" > /var/www/html/index.html
EOF
  )

  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
}

resource "aws_autoscaling_group" "web" {
  desired_capacity     = 2
  max_size             = 4
  min_size             = 1
  vpc_zone_identifier  = aws_subnet.public[*].id

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "web-server"
    propagate_at_launch = true
  }
}

// Application load balancer

resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "web_tg" {
  name        = "web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_autoscaling_attachment" "asg_alb_attach" {
  autoscaling_group_name = aws_autoscaling_group.web.name
  lb_target_group_arn     = aws_lb_target_group.web_tg.arn
}

//RDS
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "mysql" {
  identifier             = "webapp-db"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.user
  password               = var.pass
  db_name                = "webapp"
  multi_az               = true
  publicly_accessible    = false
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
}


//Cloud watch
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "HighCPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alert on high CPU usage"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}
