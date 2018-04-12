# OpenBLAS
FROM dev AS build
RUN apk add linux-headers

# Couldn't compile this (stable?) release version, only develop worked!
#ENV OPENBLAS_VERSION=0.2.20
#RUN wget --quiet https://github.com/xianyi/OpenBLAS/archive/v${OPENBLAS_VERSION}.tar.gz
#RUN tar zxf v${OPENBLAS_VERSION}.tar.gz

RUN wget --quiet https://github.com/xianyi/OpenBLAS/archive/develop.zip
RUN unzip develop.zip
WORKDIR OpenBLAS-develop

FROM build as build-lp64
RUN make NO_LAPACK=0 INTERFACE64=0 BINARY=64 DYNAMIC_ARCH=1 USE_OPENMP=1 LIBNAMESUFFIX=lp64
RUN make LIBNAMESUFFIX=lp64 PREFIX=/opt/openblas-lp64 install

FROM build as build-ilp64
RUN make NO_LAPACK=0 INTERFACE64=1 BINARY=64 DYNAMIC_ARCH=1 USE_OPENMP=1 LIBNAMESUFFIX=ilp64
RUN make LIBNAMESUFFIX=ilp64 PREFIX=/opt/openblas-ilp64 install

FROM scratch
COPY --from=build-lp64 /opt/openblas-lp64 /opt/openblas-lp64
COPY --from=build-ilp64 /opt/openblas-ilp64 /opt/openblas-ilp64
