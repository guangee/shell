FROM golang:1.22-alpine AS builder

WORKDIR /src
COPY go.mod ./
COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /tcp-proxy .

FROM alpine:3.20

RUN apk add --no-cache ca-certificates tzdata \
    && adduser -D -H -u 10001 proxy

COPY --from=builder /tcp-proxy /usr/local/bin/tcp-proxy

USER proxy
EXPOSE 443

ENTRYPOINT ["/usr/local/bin/tcp-proxy"]
