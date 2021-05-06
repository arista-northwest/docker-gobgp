FROM alpine:latest

USER root
WORKDIR /root
EXPOSE 50051
RUN \
    apk add --no-cache go

ENV GOPATH /go
ENV PATH /go/bin:$PATH

RUN apk add --no-cache \
    gcc \
    git \
    linux-headers \
    musl-dev && \
    mkdir -p /go/src && \
    mkdir -p /go/bin && \
    go get -u github.com/golang/dep/cmd/dep

RUN go get -d github.com/osrg/gobgp || exit 0

RUN \
    cd ${GOPATH}/src/github.com/osrg/gobgp/cmd && \
    go install ./gobgp && \
    go install ./gobgpd

FROM alpine:latest

COPY --from=0 /go/bin/gobgp  /usr/local/bin/gobgp
COPY --from=0 /go/bin/gobgpd /usr/local/bin/gobgpd

ENTRYPOINT ["/usr/local/bin/gobgpd", "-f", "gobgpd.conf"]