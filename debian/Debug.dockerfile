FROM --platform=$BUILDPLATFORM debian:bullseye

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt upgrade -y \
    && apt install -y \
        build-essential pkg-config git \
        bison flex libbrotli-dev \
        libboost-all-dev libicu-dev icu-devtools \
        openssl libssl-dev zlib1g zlib1g-dev

ARG ninja_Version="master"
WORKDIR /tmp/build/ninja
RUN git clone https://github.com/ninja-build/ninja -b ${ninja_Version} `pwd` \
    && python3 configure.py --bootstrap \
    && cp ninja /usr/local/bin && cd && rm -rf /tmp/build/ninja

ARG cmake_Version="v3.21.1"
WORKDIR /tmp/build/cmake
RUN git clone https://github.com/Kitware/CMake -b ${cmake_Version} `pwd` \
    && ./bootstrap \
        --prefix=/usr/local \
        --generator=Ninja \
        --parallel=48 \
    && ninja install && cd && rm -rf /tmp/build/cmake

ARG pg_Version="REL_13_3"
WORKDIR /tmp/build/pg
RUN git clone https://github.com/postgres/postgres -b ${pg_Version} `pwd` \
    && ./configure \
        --without-readline \
        --prefix=/usr/local \
        --with-icu \
        --with-openssl \
        --enable-debug \
    && make -j 48 && make install && cd && rm -rf /tmp/build/pg

ARG ws_Version="0.8.2"
WORKDIR /tmp/build/ws
RUN git clone https://github.com/zaphoyd/websocketpp -b ${ws_Version} `pwd` \
    && cmake -GNinja . \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_STANDARD_REQUIRED=ON \
    && ninja install && cd && rm -rf /tmp/build/ws

ARG Protobuf_Version="v3.17.3"
WORKDIR /tmp/build/protobuf
RUN git clone https://github.com/protocolbuffers/protobuf -b ${Protobuf_Version} `pwd` \
    && cmake -GNinja cmake \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_STANDARD_REQUIRED=ON \
        -Dprotobuf_BUILD_TESTS=OFF \
    && ninja install && cd && rm -rf /tmp/build/protobuf

ARG cares_Version="cares-1_17_1"
WORKDIR /tmp/build/cares
RUN git clone https://github.com/c-ares/c-ares -b ${cares_Version} `pwd` \
    && cmake -GNinja . \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_STANDARD_REQUIRED=ON \
        -DCARES_STATIC=ON \
        -DCARES_SHARED=OFF \
        -DCARES_BUILD_TESTS=OFF \
    && ninja install && cd && rm -rf /tmp/build/cares

ARG abseil_Version="20210324.2"
WORKDIR /tmp/build/absl
RUN git clone https://github.com/abseil/abseil-cpp -b ${abseil_Version} `pwd` \
    && cmake -GNinja . \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_STANDARD_REQUIRED=ON \
        -DABSL_ENABLE_INSTALL=ON \
        -DBUILD_TESTING=OFF \
    && ninja install && cd && rm -rf /tmp/build/absl

ARG re2_Version="2021-08-01"
WORKDIR /tmp/build/re2
RUN git clone https://github.com/google/re2 -b ${re2_Version} `pwd` \
    && cmake -GNinja . \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_STANDARD_REQUIRED=ON \
        -DRE2_BUILD_TESTING=OFF \
    && ninja install && cd && rm -rf /tmp/build/re2

ARG gRPC_Version="v1.39.0"
WORKDIR /tmp/build/grpc
RUN git clone https://github.com/grpc/grpc -b ${gRPC_Version} `pwd` \
    && cmake -GNinja . \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_STANDARD_REQUIRED=ON \
        -DgRPC_BUILD_CSHARP_EXT=OFF \
        -DgRPC_ZLIB_PROVIDER=package \
        -DgRPC_CARES_PROVIDER=package \
        -DgRPC_RE2_PROVIDER=package \
        -DgRPC_SSL_PROVIDER=package \
        -DgRPC_PROTOBUF_PROVIDER=package \
        -DgRPC_ABSL_PROVIDER=package \
        -DgRPC_BUILD_TESTS=OFF \
    && ninja install && cd && rm -rf /tmp/build/grpc

ARG cpprest_Version="2.10.18"
WORKDIR /tmp/build/cpprest
RUN git clone https://github.com/microsoft/cpprestsdk -b ${cpprest_Version} `pwd` \
   && cmake -GNinja Release \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_STANDARD_REQUIRED=ON \
        -DBUILD_TESTS=OFF \
        -DBUILD_SAMPLES=OFF \
        -DBoost_USE_STATIC_LIBS=ON \
        -DBUILD_SHARED_LIBS=OFF \
    && ninja install && cd && rm -rf /tmp/build/cpprest

ARG nlohmann_json_Version="develop"
WORKDIR /tmp/build/json
RUN git clone https://github.com/nlohmann/json -b ${nlohmann_json_Version} `pwd` \
    && cmake -GNinja . \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_STANDARD_REQUIRED=ON \
        -DJSON_BuildTests=OFF \
    && ninja install && cd && rm -rf /tmp/build/json

ARG tao_Version="main"
WORKDIR /tmp/build/taopq
RUN git clone https://github.com/taocpp/taopq -b ${tao_Version} `pwd` \
    && cmake -GNinja . \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_STANDARD_REQUIRED=ON \
        -DTAOPQ_BUILD_TESTS=OFF \
    && ninja install && cd && rm -rf /tmp/build/taopq

ARG spdlog_Version="v1.x"
WORKDIR /tmp/build/spdlog
RUN git clone https://github.com/gabime/spdlog -b ${spdlog_Version} `pwd` \
    && cmake -GNinja . \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_STANDARD_REQUIRED=ON \
        -DSPDLOG_ENABLE_PCH=ON \
        -DSPDLOG_BUILD_TESTS_HO=OFF \
    && ninja install && cd && rm -rf /tmp/build/spdlog

ARG httplib_Version="master"
WORKDIR /tmp/build/httplib
RUN git clone https://github.com/yhirose/cpp-httplib -b ${httplib_Version} `pwd` \
    && cmake -GNinja . \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_STANDARD_REQUIRED=ON \
        -DHTTPLIB_REQUIRE_OPENSSL=ON \
        -DBROTLI_USE_STATIC_LIBS=ON \
    && ninja install && cd && rm -rf /tmp/build/httplib
