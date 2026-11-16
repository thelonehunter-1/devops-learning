
FROM jenkins/jenkins:lts-jdk21

USER root

ARG KUBECTL_VERSION=v1.36.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && curl -fsSLo /tmp/kubectl \
       "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && curl -fsSLo /tmp/kubectl.sha256 \
       "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256" \
    && echo "$(cat /tmp/kubectl.sha256)  /tmp/kubectl" | sha256sum --check - \
    && install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl \
    && rm -f /tmp/kubectl /tmp/kubectl.sha256 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER jenkins
