
output "ecr_repo_url" {
  value = aws_ecr_repository.ecr.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.ecs_service.name
}
