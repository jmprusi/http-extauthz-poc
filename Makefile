.DEFAULT_GOAL := help

kind:
ifeq (, $(shell which kind))
	@{ \
	set -e ;\
	KIND_GEN_TMP_DIR=$$(mktemp -d) ;\
	cd $$KIND_GEN_TMP_DIR ;\
	go mod init tmp ;\
	GO111MODULE="on" go get sigs.k8s.io/kind@v0.9.0 ;\
	rm -rf $$KIND_GEN_TMP_DIR ;\
	}
KIND=$(GOBIN)/kind
else
KIND=$(shell which kind)
endif

.PHONY: local-setup
local-setup: kind ## Deploys a local kubernetes cluster with all the required components.
	scripts/local-setup.sh


.PHONY: help
help: ## Print this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-39s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
