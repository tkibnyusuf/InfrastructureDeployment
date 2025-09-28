pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID = credentials('account_id')
        AWS_DEFAULT_REGION="us-east-1"     
    } 
    stages {

        stage('Infrastructure Deployment') {
           environment {
             AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
             AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
             AWS_ACCOUNT_ID = credentials('account_id')
  AWS_DEFAULT_REGION = "us-east-1"
  ACTION = "apply"
           }
           steps {
              script {
  sh '''#!/usr/bin/env bash
  set -e
  rm -rf .terraform
  terraform init -input=false -reconfigure \
    -backend-config="bucket=adedeji-jenkins" \
    -backend-config="key=newresource.tfstate" \
    -backend-config="region=${AWS_DEFAULT_REGION}"
  '''
  sh "terraform validate"
  sh "terraform plan"
  sh "terraform ${action} -input=false --auto-approve"
}

            }
        }
               
     }
    }
