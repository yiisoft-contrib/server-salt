FROM debian:bullseye

RUN apt-get update && \
    apt-get -y install openssh-client python3-pip && \
    pip3 install salt-ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=400 ssh/id_rsa /root/.ssh/id_rsa

WORKDIR /app
