FROM jenkins/jenkins:lts-jdk21

USER root

ARG KUBECTL_VERSION=v1.36.1
ARG BUILDKIT_VERSION=v0.20.2

# Install kubectl and BuildKit client
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates tar \
    \
    && curl -fsSLo /tmp/kubectl \
       "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && curl -fsSLo /tmp/kubectl.sha256 \
       "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256" \
    && echo "$(cat /tmp/kubectl.sha256)  /tmp/kubectl" | sha256sum --check - \
    && install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl \
    \
    && mkdir -p /tmp/buildkit \
    && curl -fsSLo /tmp/buildkit.tar.gz \
       "https://github.com/moby/buildkit/releases/download/${BUILDKIT_VERSION}/buildkit-${BUILDKIT_VERSION}.linux-amd64.tar.gz" \
    && tar -xzf /tmp/buildkit.tar.gz -C /tmp/buildkit \
    && install -o root -g root -m 0755 /tmp/buildkit/bin/buildctl /usr/local/bin/buildctl \
    \
    && rm -rf /tmp/kubectl /tmp/kubectl.sha256 /tmp/buildkit /tmp/buildkit.tar.gz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER jenkins