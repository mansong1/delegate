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

USER root:root
ENV PACKAGES="sudo git wget unzip tar python38 jq which"
ENV KUBECTL_VERSION="v1.26.1"
RUN microdnf update \
    && microdnf install --nodocs \
    ${PACKAGES} \
    && rm -rf /var/cache/yum

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip

RUN curl -o- -L https://slss.io/install | bash \
    && ln -s ~/.serverless/bin/* /usr/local/bin

RUN curl -L https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip -o aws-sam-cli-linux-x86_64.zip \
    && unzip aws-sam-cli-linux-x86_64.zip -d sam-installation \
    && ./sam-installation/install \
    && rm -rf aws-sam-cli-linux-x86_64.zip

RUN curl https://sdk.cloud.google.com > install.sh \
    && bash install.sh --install-dir=/usr/local --disable-prompts \
    && . /usr/local/google-cloud-sdk/completion.bash.inc \
    && . /usr/local/google-cloud-sdk/path.bash.inc \
    && rm -rf install.sh

RUN pip3.8 install --upgrade pip \
    && pip3.8 --no-cache-dir install --pre azure-cli

RUN git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv \
    && echo 1.1.3 > ~/.tfenv/version \
    && ln -s ~/.tfenv/bin/* /usr/local/bin \
    && tfenv install 1.3.8

RUN curl -L https://raw.githubusercontent.com/warrensbox/tgswitch/release/install.sh | bash \
    && ln -s ~/.tgswitch/bin/* /usr/local/bin

RUN mkdir -m 777 -p /client-tools/kubectl/${KUBECTL_VERSION} \
    && curl -L https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /client-tools/kubectl/${KUBECTL_VERSION}/kubectl \
    && chmod +x /client-tools/kubectl/${KUBECTL_VERSION}/kubectl \
    && ln -s /client-tools/kubectl/${KUBECTL_VERSION}/kubectl /usr/local/bin/kubectl

ENV PATH=/opt/harness-delegate/client-tools/:$PATH
