# OpenBLAS
FROM dev AS build
RUN apk add openssh
COPY --from=armci /opt/armci /opt/armci

ENV VERSION=5.7

RUN wget --quiet https://github.com/GlobalArrays/ga/releases/download/v${VERSION}/ga-${VERSION}.tar.gz
RUN tar zxf ga-${VERSION}.tar.gz
WORKDIR ga-${VERSION}
RUN ./configure --prefix=/opt/ga --enable-i8 --with-armci=/opt/armci
#RUN make
#RUN make install

#FROM scratch
#COPY --from=build /opt/ga /opt/ga
