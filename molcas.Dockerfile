# OpenMolcas
FROM dev AS build
COPY --from=openblas /opt/openblas-ilp64 /opt/openblas-ilp64
COPY --from=hdf5 /opt/hdf5 /opt/hdf5
COPY --from=openblas /opt/openblas-lp64 /opt/openblas-lp64
COPY --from=chemps2 /opt/chemps2 /opt/chemps2

ENV MOLCAS_VERSION=master-o180408-0800

RUN wget --quiet https://gitlab.com/Molcas/OpenMolcas/repository/${MOLCAS_VERSION}/archive.tar.gz
RUN mkdir OpenMolcas
RUN tar zxf archive.tar.gz -C OpenMolcas --strip-components=1
WORKDIR OpenMolcas/
RUN mkdir build
WORKDIR build/
# There are a bunch of tricks here that should be actually solved
# by fixing the CMakeLists.txt file in Molcas.
# 1. We're setting LIBOPENBLAS directly because we use the _ilp64 suffix and
#    that is not checked for. To make it work, we also need to set the
#    OPENBLASROOT_LAST to be the same as OPENBLASROOT, otherwise LIBOPENBLAS
#    will be cleared from cache.
#    The proper solution would be to allow an OPENBLAS_NAME variable to be added in
#    addition to openblas when searching for the library.
# 2. We're not picking up the Fortran libraries for HDF5, so we need to set
#    the CMAKE_LIBRARY_PATH to point to the HDF5 libraries, so that the
#    CheMPS2 config can find and set them.
#    We should probably just add Fortran detection for HDF5 by default, even
#    if the Fortran libraries are missing, we would just have a NOTFOUND entry
#    and could check for that during CheMPS2 config.
RUN cmake \
 -DHDF5=ON -DHDF5_ROOT=/opt/hdf5 \
 -DLINALG=OpenBLAS -DOPENBLASROOT=/opt/openblas-ilp64 -DOPENBLASROOT_LAST=/opt/openblas-ilp64 -DLIBOPENBLAS=/opt/openblas-ilp64/lib/libopenblas_ilp64.so \
 -DCHEMPS2=ON -DCHEMPS2_DIR=/opt/chemps2/bin -DCMAKE_LIBRARY_PATH=/opt/hdf5/lib \
 ../
RUN make
RUN make install

FROM alpine as runtime
RUN apk add --no-cache libgcc libstdc++ libgfortran libgomp
RUN apk add --no-cache perl python3 py3-parsing
COPY --from=openblas /opt/openblas-ilp64 /opt/openblas-ilp64
COPY --from=hdf5 /opt/hdf5 /opt/hdf5
COPY --from=openblas /opt/openblas-lp64 /opt/openblas-lp64
COPY --from=chemps2 /opt/chemps2 /opt/chemps2
COPY --from=build /opt/molcas /opt/molcas
ENV PATH=/opt/molcas/sbin:/opt/chemps2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/opt/chemps2/lib64:/opt/hdf5/lib:/opt/openblas-lp64/lib
ENV MOLCAS=/opt/molcas
RUN mkdir /proj
WORKDIR /proj
RUN adduser -D molcas
USER molcas
ENTRYPOINT ["/opt/molcas/sbin/pymolcas"]
