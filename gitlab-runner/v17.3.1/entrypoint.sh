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


gitlab-runner register --non-interactive \
    --url ${GITLAB_URL}/ci \
    --registration-token ${CI_TOKEN} \
    --name gitlab-runner \
    --tag-list ${TAG_NAME} \
    --run-untagged=true \
    --executor docker \
    --builds-dir /home/gitlab-runner \
    --docker-pull-policy if-not-present \
    --docker-image ubuntu:22.04 \
    --docker-volumes "/root/.m2:/root/.m2:rw" \
    --docker-volumes "/root/.gradle/wrapper:/root/.gradle/wrapper" \
    --docker-volumes "/root/.npm:/root/.npm" \
    --docker-volumes "/root/.kube/config:/root/.kube/config" \
    --docker-volumes "/usr/bin/docker:/usr/bin/docker" \
    --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
    --docker-volumes "/usr/bin/kubectl:/usr/bin/kubectl" \
    --docker-volumes "/usr/bin/docker-compose:/usr/bin/docker-compose" \
    --config "/etc/gitlab-runner/config.toml" \
    --docker-tlsverify false

echo "gitlab-runner register finish" | tee /demo.txt

# launch gitlab-runner passing all arguments
exec gitlab-runner "$@"
