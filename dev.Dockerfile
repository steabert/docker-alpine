FROM alpine:edge
RUN echo "http://mirror.leaseweb.com/alpine/edge/testing" >> /etc/apk/repositories
RUN apk update
RUN apk add gcc g++ gfortran
RUN apk add cmake make ninja
RUN apk add perl python3
RUN apk add wget
