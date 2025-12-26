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
    TF_DIR  = 'terraform'
    APP_DIR = 'app'
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

    stage('Build & Push Docker Image') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        script {
          def ecr = sh(
            script: "cd terraform && terraform output -raw ecr_repo_url || true",
            returnStdout: true
          ).trim()

          sh """
            aws ecr get-login-password | docker login --username AWS --password-stdin ${ecr}
            docker build -t ${ecr}:latest app
            docker push ${ecr}:latest
          """
        }
      }
    }

    stage('Terraform Apply / Destroy') {
      steps {
        dir(TF_DIR) {
          sh "terraform ${params.ACTION} -auto-approve"
        }
      }
    }
  }

  post {
    success {
      echo "Terraform ${params.ACTION} completed successfully"
    }
  }
}
