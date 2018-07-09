FROM ubuntu:16.04

RUN groupadd --gid 1000 rippled \
  && useradd --uid 1000 --gid rippled --shell /bin/bash --create-home rippled

RUN buildDeps='build-essential cmake doxygen libprotobuf-dev libssl-dev wget' \
  && boostVersion='1.67.0' \
  && rippledVersion='1.0.1' \
  && apt update && apt install -y ca-certificates protobuf-compiler $buildDeps --no-install-recommends \
  && mkdir build \
  && cd build \
  && wget -O boost.tar.gz https://dl.bintray.com/boostorg/release/$boostVersion/source/boost_$(echo $boostVersion | tr . _).tar.gz \
  && tar -xf boost.tar.gz \
  && cd boost_$(echo $boostVersion | tr . _) \
  && ./bootstrap.sh --with-libraries=chrono,context,coroutine,date_time,filesystem,program_options,regex,serialization,system,thread \
  && ./b2 link=shared -j$(nproc) \
  && ./b2 install \
  && cd .. \
  && wget -O rippled.tar.gz https://github.com/ripple/rippled/archive/$rippledVersion.tar.gz \
  && tar -xf rippled.tar.gz \
  && cmake ./rippled-$rippledVersion \
  && make -j$(nproc) \
  && strip -o /home/rippled/rippled rippled \
  && chown rippled /home/rippled/rippled \
  && rm -rf \
    /build \
    /usr/local/include/boost \
  && apt purge -y --auto-remove $buildDeps

USER rippled
ENTRYPOINT ["/home/rippled/rippled"]
