FROM --platform=$BUILDPLATFORM gcc:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends cmake clang-14 clang++-14 && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libboost-dev libboost-system-dev libboost-date-time-dev


RUN ln -sf /usr/bin/clang-14 /usr/bin/clang && \
    ln -sf /usr/bin/clang++-14 /usr/bin/clang++


WORKDIR /app

COPY . .

WORKDIR /app/cicd

RUN ./build_stage.sh

EXPOSE 8080

CMD ../build/app-api
