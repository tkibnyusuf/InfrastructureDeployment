pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = "us-east-1"
    ACTION             = "apply"
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

# Install AWS CLI locally if missing (no sudo, no unzip needed)
if ! command -v aws >/dev/null 2>&1; then
  ARCH=$(uname -m); [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ] && ARCH_ARCH=x86_64 || ARCH_ARCH=aarch64
  curl -sSLo awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH_ARCH}.zip"
  rm -rf aws "$WORKSPACE/aws-cli" "$WORKSPACE/bin"
  python3 - <<'PY'
import zipfile; zipfile.ZipFile('awscliv2.zip').extractall('.')
PY
  ./aws/install -i "$WORKSPACE/aws-cli" -b "$WORKSPACE/bin"
  export PATH="$WORKSPACE/bin:$PATH"
fi

aws --version
aws sts get-caller-identity

rm -rf .terraform
terraform init -input=false -reconfigure \
  -backend-config="bucket=adedeji-jenkins" \
  -backend-config="key=newresource.tfstate" \
  -backend-config="region=${AWS_DEFAULT_REGION}"
terraform apply -input=false --auto-approve
'''
      }
    }
  }
}
