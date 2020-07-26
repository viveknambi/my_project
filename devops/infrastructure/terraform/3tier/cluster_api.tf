resource "aws_ecr_repository" "api" {
  name = "three_tier_api"
}

resource "aws_cloudwatch_log_group" "api" {
  name = "api-${var.application_name}"

  tags = {
    Application = "${var.application_name}"
    Environment = "${var.environment_name}"
  }
}

data "template_file" "api_task" {
  template = "${file("${path.module}/tasks/api_definition.json")}"

  vars {
    image        = "${aws_ecr_repository.api.repository_url}"
    database_url = "postgresql://${var.root_db_user}:${var.root_db_password}@${aws_db_instance.main.address}:${var.db_port}/${var.db_name}?encoding=utf8&pool=40"
    port         = "3000"
    region       = "${var.region}"
    log_group    = "${aws_cloudwatch_log_group.api.name}"
  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.environment_name}_api"
  container_definitions    = "${data.template_file.api_task.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}

# Everything following here needs to be commented-out the first time this file
# is run. Otherwise, this data.aws_ecs_task_definition doesn't work.
data "aws_ecs_task_definition" "api" {
  task_definition = "${aws_ecs_task_definition.api.family}"
}

resource "aws_ecs_service" "api" {
  name            = "api-${var.environment_name}"
  task_definition = "${aws_ecs_task_definition.api.family}:${max("${aws_ecs_task_definition.api.revision}", "${data.aws_ecs_task_definition.api.revision}")}"
  desired_count   = 2
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.3tier.id}"
  depends_on      = [
    "aws_iam_role_policy.ecs_service_role_policy",
    "aws_alb_target_group.api",
  ]

  network_configuration {
    security_groups  = ["${aws_security_group.api_internal.id}"]
    subnets          = ["${aws_subnet.frontend1.id}", "${aws_subnet.frontend2.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.api.arn}"
    container_name   = "api"
    container_port   = "3000"
  }

  deployment_controller {
    type = "ECS"
  }
  deployment_maximum_percent = "200"
  deployment_minimum_healthy_percent = "50"

  tags = {
    Application = "${var.application_name}"
    Environment = "${var.environment_name}"
  }
  propagate_tags = "SERVICE"
}
