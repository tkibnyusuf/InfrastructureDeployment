#!/usr/bin/env bash
set -euo pipefail

# ---- Java 17 (user-space via SDKMAN) ----
if ! command -v java >/dev/null 2>&1; then
  curl -s "https://get.sdkman.io" | bash
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  yes | sdk install java 17.0.12-tem >/dev/null
fi
java -version

# ---- Jenkins (user-mode) ----
export JENKINS_HOME="$HOME/jenkins_home"
mkdir -p "$JENKINS_HOME"
[ -f "$HOME/jenkins.war" ] || curl -L -o "$HOME/jenkins.war" https://get.jenkins.io/war-stable/latest/jenkins.war

# Bind to localhost for safety (use SSH tunnel to access)
J_ADDR=127.0.0.1
J_PORT=8080
pgrep -f 'jenkins\.war' >/dev/null || nohup java -jar "$HOME/jenkins.war" --httpPort=$J_PORT --httpListenAddress=$J_ADDR > "$HOME/jenkins.log" 2>&1 &

echo "Waiting for Jenkins initial admin password..."
for i in {1..90}; do
  [ -f "$JENKINS_HOME/secrets/initialAdminPassword" ] && break
  sleep 2
done

if [ -f "$JENKINS_HOME/secrets/initialAdminPassword" ]; then
  echo "JENKINS_INITIAL_ADMIN_PASSWORD: $(cat "$JENKINS_HOME/secrets/initialAdminPassword")"
else
  echo "Still generating… check log: tail -n 200 $HOME/jenkins.log"
fi
echo "Open Jenkins via SSH tunnel: ssh -N -L 8080:127.0.0.1:8080 <user>@<server>  ->  http://localhost:8080"

# ---- Terraform (user-space to ~/bin) ----
VER=1.9.5
ARCH=$(dpkg --print-architecture)          # amd64 or arm64
TF_ZIP=/tmp/terraform.zip
mkdir -p "$HOME/bin"
curl -fsSL -o "$TF_ZIP" "https://releases.hashicorp.com/terraform/${VER}/terraform_${VER}_linux_${ARCH}.zip"
if command -v unzip >/dev/null 2>&1; then
  unzip -o "$TF_ZIP" -d "$HOME/bin"
else
  python3 - <<'PY'
import zipfile, os
zipfile.ZipFile('/tmp/terraform.zip').extractall(os.path.expanduser('~/bin'))
PY
fi
echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
export PATH="$HOME/bin:$PATH"
terraform -version || true

echo 'clearing screen...' && sleep 5
clear
echo 'jenkins is installed'
echo 'this is the default password :' $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
