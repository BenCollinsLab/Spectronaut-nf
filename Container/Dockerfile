FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Install required system packages
RUN apt-get update && \
    apt-get install -y \
        wget \
        ca-certificates \
        libgomp1 && \
    rm -rf /var/lib/apt/lists/*

# Install Microsoft repository and .NET 8
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb \
        -O /tmp/packages-microsoft-prod.deb && \
    dpkg -i /tmp/packages-microsoft-prod.deb && \
    rm -f /tmp/packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-8.0 && \
    rm -rf /var/lib/apt/lists/*

# Copy the version-specific Spectronaut installer
COPY Spectronaut_*.deb /opt/Spectronaut.deb

# Install Spectronaut
RUN apt-get update && \
    apt-get install -y /opt/Spectronaut.deb && \
    rm -f /opt/Spectronaut.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/bin:${PATH}"

CMD ["spectronaut"]
