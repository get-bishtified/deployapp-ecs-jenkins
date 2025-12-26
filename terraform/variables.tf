
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for ECS service"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for ECS service"
  type        = list(string)
}
