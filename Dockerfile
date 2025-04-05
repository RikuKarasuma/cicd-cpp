FROM --platform=$BUILDPLATFORM gcc:latest

# Install clang++-17/llvm, cmake & libboost
RUN apt-get update && \
    apt-get install -y wget gnupg lsb-release software-properties-common cmake && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libboost-dev libboost-system-dev libboost-date-time-dev && \
    rm -rf /var/lib/apt/lists/*

# Add llvm script for installing clang++ 17
RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 17 && \
    rm llvm.sh

# Set clang 17 as default
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-17 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-17 100

# Verify installation
RUN clang++ --version

WORKDIR /app

COPY . .

WORKDIR /app/cicd

RUN ./build_stage.sh

EXPOSE 8080

CMD ../build/app-api
