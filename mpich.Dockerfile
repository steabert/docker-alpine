# OpenBLAS
FROM dev AS build

ENV VERSION=3.2.1

RUN wget --quiet http://www.mpich.org/static/downloads/${VERSION}/mpich-${VERSION}.tar.gz
RUN tar zxf mpich-${VERSION}.tar.gz
WORKDIR mpich-${VERSION}

RUN ./configure --prefix=/opt/mpich
RUN make
RUN make install

FROM scratch
COPY --from=build /opt/mpich /opt/mpich
