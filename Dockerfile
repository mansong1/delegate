ARG BASE_IMAGE_TAG
FROM harness/delegate:${BASE_IMAGE_TAG}
LABEL image.authors="martin.ansong@harness.io"

# ============================================
# Install Operating System packages
# - from default repositories
# ============================================
# The harness immutable images are based on Red Hat UBI minimal.
# The package manager is microdnf, it uses yum repositories.
# Operating system packages must be installed as root.

USER root

ENV NODEJS_VERSION=20

ENV PACKAGES="sudo git wget unzip tar python3 jq which nodejs"

ENV KUBECTL_VERSION="v1.30.13"

ENV HELM_VERSION="v3.18.2"

ENV KUSTOMIZE_VERSION="v5.6.0"

RUN echo -e "[nodejs]\nname=nodejs\nstream=${NODEJS_VERSION}\nprofiles=\nstate=enabled\n" > /etc/dnf/modules.d/nodejs.module

RUN microdnf -y update \
    && microdnf install --nodocs \
    ${PACKAGES} \
    && rm -rf /var/cache/yum

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Install serverless framework
RUN npm install -g serverless

# Install AWS SAM CLI
RUN curl -L https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip -o aws-sam-cli-linux-x86_64.zip && \
    unzip aws-sam-cli-linux-x86_64.zip -d sam-installation && \
    ./sam-installation/install && \
    rm -rf aws-sam-cli-linux-x86_64.zip sam-installation

# Install Google Cloud SDK
RUN curl https://sdk.cloud.google.com > install.sh && \
    bash install.sh --install-dir=/usr/local --disable-prompts && \
    rm -rf install.sh

# Install Azure CLI
RUN pip3.8 install --upgrade pip \
    && pip3.8 --no-cache-dir install --pre azure-cli

# Install tfenv and Terraform
RUN git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv \
    && ln -s ~/.tfenv/bin/* /usr/local/bin

RUN tfenv install 1.12.2 && tfenv use 1.12.2

# Install tgswitch and Terragrunt
RUN curl -L https://raw.githubusercontent.com/warrensbox/tgswitch/release/install.sh | bash \
    && ln -s ~/.tgswitch/bin/* /usr/local/bin \
    && tgswitch 0.81.5

# Install Kubernetes CLI
RUN mkdir -m 777 -p /client-tools/kubectl/${KUBECTL_VERSION} \
    && curl -L https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /client-tools/kubectl/${KUBECTL_VERSION}/kubectl \
    && chmod +x /client-tools/kubectl/${KUBECTL_VERSION}/kubectl \
    && ln -s /client-tools/kubectl/${KUBECTL_VERSION}/kubectl /usr/local/bin/kubectl

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod +x get_helm.sh && \
    ./get_helm.sh && \
    rm -f get_helm.sh

ENV PATH=/opt/harness-delegate/client-tools/:$PATH
