# Step 1: Build the Go binary

FROM golang:1.20.7-alpine3.18 AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY ./cmd .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./server

# Step 2: Run the Go binary in a scratch container

FROM alpine:3.18.2

LABEL org.opencontainers.image.source https://github.com/filouz/nethops

RUN apk --no-cache add ca-certificates curl
RUN apk update

RUN apk add zsh git
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="ys"/g' /root/.zshrc

RUN apk add openssl openvpn iptables

RUN apk add nano tmux make bind-tools mtr bash

ENV SCRIPTS_DIR=/scripts
ENV	OVPN_DIR=/ovpn

COPY ./scripts $SCRIPTS_DIR

WORKDIR /root/

COPY --from=builder /app/main .

ENTRYPOINT ["./main"]
