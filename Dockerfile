FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive

# 2022/02/03
ENV TPM_REFERENCE_COMMIT=d638536d0fe01acd5e39ffa1bd100b3da82d92c7

# Install some basic tools we're going to need
RUN apt-get update && apt-get install -y git autoconf-archive pkg-config build-essential automake gcc libssl-dev && rm -rf /var/lib/apt/lists/*

# Download the TPM reference code at our preferred commit, and compile it
RUN mkdir ms-tpm-20-ref && cd ms-tpm-20-ref \
&& git init \
&& git remote add origin https://github.com/microsoft/ms-tpm-20-ref.git \
&& git fetch origin ${TPM_REFERENCE_COMMIT} \
&& git reset --hard FETCH_HEAD \
&& cd ./TPMCmd && ./bootstrap && ./configure && make \
&& cp ./Simulator/src/tpm2-simulator /

FROM mcr.microsoft.com/dotnet/sdk:6.0
COPY --from=0 /tpm2-simulator .

# Install OpenSSH
RUN apt-get update && apt-get install -y openssh-client && rm -rf /var/lib/apt/lists/*

LABEL org.opencontainers.image.source="https://github.com/chrisfenner/tpm-simulator-container"
LABEL org.opencontainers.image.description="This is a Docker image containing a TPM simulator plus related tools for testing."
LABEL org.opencontainers.image.licenses="BSD-3-Clause"
