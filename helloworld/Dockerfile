FROM golang:alpine AS builder
WORKDIR $GOPATH/src/mypackage/myapp/
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /go/bin/helloworld

FROM scratch
COPY --from=builder /go/bin/helloworld /go/bin/helloworld
ENTRYPOINT ["/go/bin/helloworld"]

