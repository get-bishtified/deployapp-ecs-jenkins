
pipeline {
  agent any
  parameters {
    choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Terraform action')
  }
  environment {
    TF_DIR = 'terraform'
    APP_DIR = 'app'
    AWS_REGION = 'ap-south-1'
    TF_CLI_ARGS = '-no-color'
  }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Terraform Init') { steps { dir(TF_DIR) { sh 'terraform init' } } }
    stage('Terraform Apply') {
      when { expression { params.ACTION == 'apply' } }
      steps { dir(TF_DIR) { sh 'terraform apply -auto-approve' } }
    }
    stage('Build & Push Image') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        script {
          def ecr = sh(script: "cd terraform && terraform output -raw ecr_repo_url", returnStdout: true).trim()
          sh '''
            aws ecr get-login-password --region ap-south-1 |
            docker login --username AWS --password-stdin ${ecr}
            docker build -t ${ecr}:latest app
            docker push ${ecr}:latest
          '''
        }
      }
    }
    stage('Deploy to ECS') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        script {
          def cluster = sh(script: "cd terraform && terraform output -raw ecs_cluster_name", returnStdout: true).trim()
          def service = sh(script: "cd terraform && terraform output -raw ecs_service_name", returnStdout: true).trim()
          sh "aws ecs update-service --cluster ${cluster} --service ${service} --force-new-deployment --region ap-south-1"
        }
      }
    }
    stage('Terraform Destroy') {
      when { expression { params.ACTION == 'destroy' } }
      steps { dir(TF_DIR) { sh 'terraform destroy -auto-approve' } }
    }
  }
}
