resource "aws_ecs_cluster" "space_cluster" {
  cluster_name = "space_cluster"
}

resource "aws_ecs_service" "space" {
  name = "space"
  cluster = aws_ecs_cluster.space_cluster.id
  task_definition = aws_ecs_task_definition 
}
