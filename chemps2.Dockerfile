# CheMPS2
FROM dev AS build
COPY --from=openblas /opt/openblas-lp64 /opt/openblas-lp64
COPY --from=hdf5 /opt/hdf5 /opt/hdf5

ENV CHEMPS2_VERSION=1.8.7

RUN wget --quiet https://github.com/SebWouters/CheMPS2/archive/v${CHEMPS2_VERSION}.tar.gz
RUN tar zxf v${CHEMPS2_VERSION}.tar.gz
WORKDIR CheMPS2-${CHEMPS2_VERSION}
RUN mkdir build/
WORKDIR build/
# LD_LIBRARY_PATH tricks FindLAPACK to search in the correct place
RUN cmake \
 -DCMAKE_INSTALL_PREFIX=/opt/chemps2 \
 -DLAPACK_LIBRARIES='/opt/openblas-lp64/lib/libopenblas_lp64.so' \
 -DHDF5_ROOT=/opt/hdf5 \
 -DWITH_MPI=OFF \
 -DCMAKE_RANLIB=/usr/bin/gcc-ranlib \
 -DCMAKE_AR=/usr/bin/gcc-ar \
 ../
RUN make
RUN make install

FROM scratch
COPY --from=build /opt/chemps2 /opt/chemps2
