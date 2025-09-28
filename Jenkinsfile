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
# install AWS CLI v2 locally for this build
ARCH=$(uname -m); URL="https://awscli.amazonaws.com/awscli-exe-linux-$([ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ] && echo x86_64 || echo aarch64).zip"
curl -sSLo awscliv2.zip "$URL"
rm -rf aws "$WORKSPACE"/aws-cli "$WORKSPACE"/bin
(unzip -q awscliv2.zip || python3 - <<'PY'
import zipfile; zipfile.ZipFile('awscliv2.zip').extractall('.')
PY
)
./aws/install -i "$WORKSPACE/aws-cli" -b "$WORKSPACE/bin"
export PATH="$WORKSPACE/bin:$PATH"
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
