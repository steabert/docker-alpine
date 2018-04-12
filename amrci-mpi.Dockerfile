# OpenBLAS
FROM dev AS build
RUN apk add autoconf automake libtool

ENV VERSION=2016-01-04

RUN wget --quiet https://github.com/steabert/armci-mpi/archive/v${VERSION}.tar.gz
RUN tar zxf v${VERSION}.tar.gz
WORKDIR armci-mpi-${VERSION}

RUN libtoolize
RUN ./autogen.sh
RUN ./configure --prefix=/opt/armci
RUN make
RUN make install

FROM scratch
COPY --from=build /opt/armci /opt/armci
