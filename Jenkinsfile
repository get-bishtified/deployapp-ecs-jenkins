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
    TF_DIR     = 'terraform'
    APP_DIR    = 'app'
    AWS_REGION = 'ap-south-1'
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

    stage('Terraform Apply (Infra First)') {
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
          def ecr = sh(
            script: "cd terraform && terraform output -raw ecr_repo_url",
            returnStdout: true
          ).trim()

          sh """
            aws ecr get-login-password --region ${AWS_REGION} \
              | docker login --username AWS --password-stdin ${ecr}

            docker build -t ${ecr}:latest ${APP_DIR}
            docker push ${ecr}:latest
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
      echo "Terraform ${params.ACTION} completed successfully"
    }
    failure {
      echo "Terraform ${params.ACTION} failed"
    }
  }
}
