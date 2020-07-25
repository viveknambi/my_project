resource "aws_ecr_repository" "web" {
  name = "three_tier_web"
}

resource "aws_cloudwatch_log_group" "web" {
  name = "web-${var.application_name}"

  tags = {
    Application = "${var.application_name}"
    Environment = "${var.environment_name}"
  }
}

data "template_file" "web_task" {
  template = "${file("${path.module}/tasks/web_definition.json")}"

  vars {
    image     = "${aws_ecr_repository.web.repository_url}"
    api_url   = "https://api.3tier.robkinyon.org"
    port      = "3000"
    region    = "${var.region}"
    log_group = "${aws_cloudwatch_log_group.web.name}"
  }
}

resource "aws_ecs_task_definition" "web" {
  family                   = "${var.environment_name}_web"
  container_definitions    = "${data.template_file.web_task.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}

# Everything following here needs to be commented-out the first time this file
# is run. Otherwise, this data.aws_ecs_task_definition doesn't work.
data "aws_ecs_task_definition" "web" {
  task_definition = "${aws_ecs_task_definition.web.family}"
}

resource "aws_ecs_service" "web" {
  name            = "web-${var.environment_name}"
  task_definition = "${aws_ecs_task_definition.web.family}:${max("${aws_ecs_task_definition.web.revision}", "${data.aws_ecs_task_definition.web.revision}")}"
  desired_count   = 2
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.3tier.id}"
  depends_on      = [
    "aws_iam_role_policy.ecs_service_role_policy",
    "aws_alb_target_group.web",
  ]

  network_configuration {
    security_groups  = ["${aws_security_group.web_internal.id}"]
    subnets          = ["${aws_subnet.frontend1.id}", "${aws_subnet.frontend2.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.web.arn}"
    container_name   = "web"
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
