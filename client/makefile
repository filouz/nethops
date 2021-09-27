



client: client_build # client_push

client_build:
	docker build $(CLIENT_PATH) -f $(ROOT_PATH)/docker/client/Dockerfile -t $(REGISTRY)/nethops/client:$(TAG)

client_push:
	docker push $(REGISTRY)/nethops/client:$(TAG)

client_run: client_build
	docker run -it --rm \
		--privileged \
		-v $(ROOT_PATH)/.vault/ovpn:/ovpn \
		$(REGISTRY)/nethops/client:$(TAG) zsh

#########

client_dev_build:
	docker build $(CLIENT_PATH) -f $(ROOT_PATH)/docker/client/Dockerfile.dev -t $(REGISTRY)/nethops/client:$(TAG_DEV)

client_dev: client_dev_build 
	docker run -it --rm \
		--privileged \
		-v $(CLIENT_PATH):/repo \
		-v $(CLIENT_PATH)/scripts:/scripts \
		-v $(ROOT_PATH)/.vault/ovpn:/ovpn \
		-e SCRIPTS_DIR=/scripts \
		-e OVPN_DIR=/ovpn \
		-w /repo \
		--name nh_client \
		$(REGISTRY)/nethops/client:$(TAG_DEV) zsh

client_test:
	go build -o /tmp/server ./cmd/server  && /tmp/server