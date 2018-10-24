FROM ubuntu:18.04 AS builder

ENV BUILD_TAG 1.1.0

RUN apt update
RUN apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  cmake \
  doxygen \
  git \
  libprotobuf-dev \
  libssl-dev \
  protobuf-compiler \
  wget

RUN wget -O- https://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.gz | tar xz
RUN wget -O- https://github.com/ripple/rippled/archive/$BUILD_TAG.tar.gz | tar xz

WORKDIR /boost_1_68_0
RUN ./bootstrap.sh --with-libraries=chrono,context,coroutine,date_time,filesystem,program_options,regex,serialization,system,thread
RUN ./b2 install link=shared -j$(nproc)

WORKDIR /build
RUN cmake -DCMAKE_BUILD_TYPE=Release ../rippled-$BUILD_TAG
RUN make -j$(nproc)
RUN strip rippled


FROM ubuntu:18.04

RUN apt update \
  && apt install -y --no-install-recommends \
    protobuf-compiler \
    libssl1.1 \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/libboost_* /usr/local/lib/
COPY --from=builder /build/rippled /usr/local/bin/

RUN groupadd --gid 1000 rippled \
  && useradd --uid 1000 --gid rippled --shell /bin/bash --create-home rippled

USER rippled

# P2P && RPC
EXPOSE 51235 5005

CMD rippled
