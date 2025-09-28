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

# Download & extract (no sudo, works without unzip)
ARCH=$(uname -m); [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ] && ARCH_ARCH=x86_64 || ARCH_ARCH=aarch64
curl -sSLo awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH_ARCH}.zip"
rm -rf aws "$WORKSPACE/aws-cli" "$WORKSPACE/bin"
( unzip -q awscliv2.zip || python3 - <<'PY'
import zipfile; zipfile.ZipFile('awscliv2.zip').extractall('.')
PY
)

# Ensure installer is executable, then run via bash
chmod +x aws/install || true
bash ./aws/install -i "$WORKSPACE/aws-cli" -b "$WORKSPACE/bin" || {
  # fallback if workspace is noexec: install to /tmp
  mkdir -p /tmp/aws-cli /tmp/bin
  bash ./aws/install -i "/tmp/aws-cli" -b "/tmp/bin"
  export PATH="/tmp/bin:$PATH"
}

export PATH="$WORKSPACE/bin:$PATH"
aws --version
'''
      }
    }
  }
}
