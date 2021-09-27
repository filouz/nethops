
# TODO: FROM alpine:3.18.2
FROM alpine:3.7

LABEL org.opencontainers.image.source https://github.com/filouz/nethops

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV EASYRSA /usr/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki


RUN apk --no-cache add ca-certificates curl wget
RUN apk update

RUN apk add nano tmux make bind-tools mtr tcpdump

RUN apk add zsh git
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="ys"/g' /root/.zshrc

RUN apk add openssl openvpn squid iptables bash openvpn-auth-pam google-authenticator

ADD https://github.com/OpenVPN/easy-rsa/releases/download/v3.1.5/EasyRSA-3.1.5.tgz /tmp/easyrsa.tgz
RUN mkdir -p $EASYRSA && \
    tar -xzf /tmp/easyrsa.tgz --strip-components=1 -C $EASYRSA && \
    ln -s $EASYRSA/easyrsa /usr/local/bin

COPY conf/squid.conf /etc/squid/squid.conf

ADD ./bin /usr/local/bin

COPY ./scripts /scripts

CMD ["ovpn_run"]

