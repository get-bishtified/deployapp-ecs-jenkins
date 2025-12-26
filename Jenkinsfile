pipeline {
  agent any

  parameters {
    choice(
      name: 'ACTION',
      choices: ['apply', 'destroy'],
      description: 'Terraform action'
    )
  }

  environment {
    TF_DIR      = 'terraform'
    APP_DIR     = 'app'
    AWS_REGION  = 'ap-south-1'
    TF_CLI_ARGS = '-no-color'
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        dir(TF_DIR) {
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Apply (Infra)') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        dir(TF_DIR) {
          sh 'terraform apply -auto-approve'
        }
      }
    }

    stage('Build & Push Docker Image to ECR') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        script {
          // Get ECR repo URL from Terraform output
          def ecr = sh(
            script: "cd terraform && terraform output -raw ecr_repo_url",
            returnStdout: true
          ).trim()

          sh """
            echo "Logging into ECR: ${ecr}"

            aws ecr get-login-password --region ${AWS_REGION} \
              | docker login --username AWS --password-stdin ${ecr}

            echo "Building Docker image"
            docker build -t ${ecr}:latest ${APP_DIR}

            echo "Pushing Docker image to ECR"
            docker push ${ecr}:latest
          """
        }
      }
    }

    stage('Deploy to ECS') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        script {
          def cluster = sh(
            script: "cd terraform && terraform output -raw ecs_cluster_name",
            returnStdout: true
          ).trim()

          def service = sh(
            script: "cd terraform && terraform output -raw ecs_service_name",
            returnStdout: true
          ).trim()

          sh """
            echo "Deploying to ECS cluster: ${cluster}, service: ${service}"

            aws ecs update-service \
              --cluster ${cluster} \
              --service ${service} \
              --force-new-deployment \
              --region ${AWS_REGION}
          """
        }
      }
    }

    stage('Terraform Destroy') {
      when {
        expression { params.ACTION == 'destroy' }
      }
      steps {
        dir(TF_DIR) {
          sh 'terraform destroy -auto-approve'
        }
      }
    }
  }

  post {
    success {
      echo "Pipeline completed successfully (ACTION=${params.ACTION})"
    }
    failure {
      echo "Pipeline failed (ACTION=${params.ACTION})"
    }
  }
}
