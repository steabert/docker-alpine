# HDF5 (because the hdf5/hdf5-dev from Alpine doesn't have Fortran includes)
FROM dev AS build

ENV HDF5_VERSION=1.8.20

RUN wget --quiet https://support.hdfgroup.org/ftp/HDF5/current18/src/hdf5-${HDF5_VERSION}.tar.bz2
RUN tar jxf hdf5-${HDF5_VERSION}.tar.bz2
WORKDIR hdf5-${HDF5_VERSION}
RUN ./configure \
 --prefix=/opt/hdf5 \
 --enable-fortran \
 --enable-fortran2003 \
 --enable-cxx \
 --enable-hl \
 --disable-threaded \
 --enable-direct-vfd
RUN make
RUN make install

FROM scratch
COPY --from=build /opt/hdf5 /opt/hdf5
