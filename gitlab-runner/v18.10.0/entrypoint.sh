#!/bin/bash
# gitlab-runner data directory
DATA_DIR="/etc/gitlab-runner"
CONFIG_FILE=${CONFIG_FILE:-$DATA_DIR/config.toml}
# custom certificate authority path
CA_CERTIFICATES_PATH=${CA_CERTIFICATES_PATH:-$DATA_DIR/certs/ca.crt}
LOCAL_CA_PATH="/usr/local/share/ca-certificates/ca.crt"

update_ca() {
  echo "Updating CA certificates..."
  cp "${CA_CERTIFICATES_PATH}" "${LOCAL_CA_PATH}"
  update-ca-certificates --fresh >/dev/null
}

if [ -f "${CA_CERTIFICATES_PATH}" ]; then
  # update the ca if the custom ca is different than the current
  cmp --silent "${CA_CERTIFICATES_PATH}" "${LOCAL_CA_PATH}" || update_ca
fi

echo "hello" | tee /demo.txt

HELPER_IMAGE=${HELPER_IMAGE:-"hub.tulan.wang/gitlab/gitlab-runner-helper:x86_64-v18.10.0"}

gitlab-runner register --non-interactive \
    --url ${GITLAB_URL}/ci \
    --token ${CI_TOKEN} \
    --name gitlab-runner \
    --executor docker \
    --docker-pull-policy if-not-present \
    --custom_build_dir-enabled=false \
    --docker-image ubuntu:22.04 \
    --docker-helper-image "${HELPER_IMAGE}" \
    --docker-volumes "/root/.m2:/root/.m2:rw" \
    --docker-volumes "/root/.gradle:/root/.gradle" \
    --docker-volumes "/root/.npm:/root/.npm" \
    --docker-volumes "/root/.kube/config:/root/.kube/config" \
    --docker-volumes "/usr/bin/docker:/usr/bin/docker" \
    --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
    --docker-volumes "/usr/bin/kubectl:/usr/bin/kubectl" \
    --docker-volumes "/usr/bin/docker-compose:/usr/bin/docker-compose" \
    --config "/etc/gitlab-runner/config.toml" \
    --docker-tlsverify false

echo "gitlab-runner register finish" | tee /demo.txt

# 减少 CI 日志缓冲：为 job 容器注入无缓冲相关环境变量，便于在 GitLab 上实时看到日志
if [ -f "${CONFIG_FILE}" ] && ! grep -q 'PYTHONUNBUFFERED' "${CONFIG_FILE}"; then
  sed -i '/executor = "docker"/a\  environment = ["PYTHONUNBUFFERED=1"]' "${CONFIG_FILE}"
fi

# launch gitlab-runner passing all arguments
exec gitlab-runner "$@"
