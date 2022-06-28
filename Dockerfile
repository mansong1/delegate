FROM harness/delegate-immutable:22.06.75511
LABEL maintainer="martin.ansong@harness.io"
USER root
RUN microdnf -y update
RUN microdnf install curl git unzip nodejs && \
    microdnf clean all
RUN git clone https://github.com/tfutils/tfenv.git ~/.tfenv && \
    ln -s ~/.tfenv/bin/* /usr/bin
RUN TERRAFORM_VERSIONS="1.2.1 1.2.2 1.2.3" \
    sh -c "for version in \$TERRAFORM_VERSIONS; do tfenv install \$version; done" \
    echo 1.2.3 > ~/.tfenv/version
RUN npm install -g serverless@3.19.0
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"