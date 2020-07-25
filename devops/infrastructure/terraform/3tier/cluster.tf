resource "aws_ecs_cluster" "3tier" {
  name = "threetier-${var.environment_name}"
}
