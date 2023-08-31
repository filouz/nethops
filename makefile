
include config.mk

REGISTRY = ghcr.io/filouz
TAG = local
TAG_DEV = dev

NAMESPACE=nethops

OVPN_CIPHER_CHAIN=AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305
OVPN_CIPHER=AES-256-GCM

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
ROOT_PATH := $(dir $(mkfile_path))
CLIENT_PATH := $(dir $(ROOT_PATH))/client

DOCKER_CMD = docker run --rm -it \
				-v $(OVPN_DATA):/etc/openvpn \
				-v $(shell pwd)/scripts:/scripts \
				-w /scripts \
				-p $(OVPN_PORT):1194/udp \
				--privileged \
				--name nethops \
				$(REGISTRY)/nethops:$(TAG)

##############################################
##############################################

all: build install

build:
	docker build $(ROOT_PATH) -f $(ROOT_PATH)/docker/server/Dockerfile -t $(REGISTRY)/nethops:$(TAG)

push:
	docker push $(REGISTRY)/nethops:$(TAG)

run:
	docker run --rm -it -d \
		-v $(OVPN_DATA):/etc/openvpn \
		-p $(OVPN_PORT):1194/udp \
		--privileged \
		--name nethops-instance \
		$(REGISTRY)/nethops:$(TAG)

install: updateConfig
	$(DOCKER_CMD) ovpn_initpki "${OVPN_CA_PWD}"

updateConfig:
	$(DOCKER_CMD) ovpn_genconfig -b -M -u udp://$(OVPN_DOMAIN) -x "$(OVPN_CA)" -T "$(OVPN_CIPHER_CHAIN)" -C "$(OVPN_CIPHER)"

uninstall:
	$(DOCKER_CMD) rm -fr /etc/openvpn 


addProfile:
	$(DOCKER_CMD) ovpn_genclient -n "$(name)" -p "$(pwd)" -c "${OVPN_CA_PWD}"
	$(DOCKER_CMD) ovpn_getclient "$(name)" combined-save
	$(DOCKER_CMD) ovpn_getclient "$(name)"

ovpnProfile:
	$(DOCKER_CMD) ovpn_getclient "$(name)" combined-save
	$(DOCKER_CMD) ovpn_getclient "$(name)"
		
revokeProfile:
	$(DOCKER_CMD) ovpn_revokeclient -n "$(name)" -a remove -c "${OVPN_CA_PWD}"



##############################################
##############################################

include $(CLIENT_PATH)/makefile