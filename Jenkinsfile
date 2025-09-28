pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = "us-east-1"
    ACTION = "apply"
  }

  stages {
    stage('Infrastructure Deployment') {
      environment {
        AWS_ACCESS_KEY_ID     = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        // If using temporary creds, also add:
        // AWS_SESSION_TOKEN      = credentials('aws_session_token')
      }
      steps {
        sh '''#!/usr/bin/env bash
set -euo pipefail

aws sts get-caller-identity

rm -rf .terraform
terraform init -input=false -reconfigure \
  -backend-config="bucket=adedeji-jenkins" \
  -backend-config="key=newresource.tfstate" \
  -backend-config="region=${AWS_DEFAULT_REGION}"

terraform validate
terraform plan -input=false -no-color
terraform ${ACTION} -input=false --auto-approve
'''
      }
    }
  }
}
