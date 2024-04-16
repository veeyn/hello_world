resource "aws_ecs_cluster" "my_fargate_cluster" {
  name = "my-fargate-cluster"
}

resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  enable_deletion_protection = false

}

output "alb_dns_name" {
  value = aws_lb.my_alb.dns_name
  description = "The DNS name of the ALB"
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "alb-target-group"
  port     = 8888
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
  target_type = "ip"

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

resource "aws_cloudwatch_log_group" "my_log_group" {
  name              = "/ecs/launch-app-task"
  retention_in_days = 30

  tags = {
    Environment = "production"
    Application = "ECS"
  }
}


resource "aws_ecs_task_definition" "launch_app_task" {
  family                   = "launch-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "my-app-container"
      image     = "${var.container_image}:${var.image_tag}"
      cpu       = 1024
      memory    = 3072
      essential = true

      portMappings = [
        {
          containerPort = 8888
          hostPort      = 8888
          protocol      = "tcp"
        },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/launch-app-task"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.my_fargate_cluster.id
  task_definition = aws_ecs_task_definition.launch_app_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  health_check_grace_period_seconds = 10

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name   = "my-app-container"
    container_port   = 8888
  }

  network_configuration {
    subnets = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups = [aws_security_group.ContainerFromALB_sg.id]
  }

  depends_on = [
    aws_lb_listener.alb_listener,
    aws_lb_target_group.alb_target_group
  ]
}
