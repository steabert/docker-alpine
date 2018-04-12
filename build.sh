#!/bin/bash
for TAG in dev hdf5 openblas chemps2 molcas
do
  echo "building ${TAG}"
  docker build -t ${TAG} -f ${TAG}.Dockerfile .
  docker tag ${TAG} steabert/alpine-${TAG}
  docker push steabert/alpine-${TAG}
done
