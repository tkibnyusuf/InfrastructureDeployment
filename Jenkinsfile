pipeline {
  agent {
    // Use docker agent with official terraform image (no terraform install needed on node)
    docker { image 'hashicorp/terraform:light' }
  }
  environment {
    AWS_DEFAULT_REGION = 'us-east-1'
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Terraform Init') {
      steps {
        // If using AWS credentials stored in Jenkins, uncomment and use withCredentials() (see note below)
        sh '''
          terraform init -reconfigure
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        sh '''
          terraform plan -out=tfplan
        '''
      }
    }

    stage('Terraform Apply') {
      steps {
        input message: "Apply Terraform changes?"
        sh '''
          terraform apply -auto-approve tfplan
        '''
      }
    }
  }
  post {
    always {
      sh 'terraform version || true'
    }
  }
}
