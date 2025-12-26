output "ecr_repo_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.python_app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.python_cluster.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.python_service.name
}
