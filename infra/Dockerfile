FROM docker:dind

WORKDIR /workspace

RUN apk update -qq && apk upgrade

# Install terraform
RUN apk add --no-cache -q terraform

# Install aws cli
RUN apk add --no-cache -q curl unzip python3 groff && \
    curl -sO https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py && \
    pip3 install awscli --upgrade && \
    rm get-pip.py

# Install kubectl
RUN curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-08-04/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv kubectl /usr/local/bin
