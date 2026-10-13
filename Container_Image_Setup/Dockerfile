FROM ubuntu:22.04

ARG SN_VERSION
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        libgomp1 && \
    rm -rf /var/lib/apt/lists/*

# Add the Microsoft package repo and install the .NET 8 runtime.
# (Skip/adjust this block if your Spectronaut .deb already pulls in dotnet8
# as a dependency via its own repo config.)
RUN wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb \
        -O /tmp/packages-microsoft-prod.deb && \
    dpkg -i /tmp/packages-microsoft-prod.deb && \
    rm /tmp/packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends dotnet-runtime-8.0 && \
    rm -rf /var/lib/apt/lists/*

# Copy the Spectronaut installer into the image and install it
COPY Spectronaut_${SN_VERSION}.deb /opt/Spectronaut_${SN_VERSION}.deb

RUN apt-get update && \
    apt-get install -y /opt/Spectronaut_${SN_VERSION}.deb && \
    rm /opt/Spectronaut_${SN_VERSION}.deb && \
    rm -rf /var/lib/apt/lists/*

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENTRYPOINT ["spectronaut"]
