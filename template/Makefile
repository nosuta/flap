# NOT RECOMMENDED TO EDIT

-include custom.mk

include core.env

# Path to the godash core package (sibling repo by default).
GODASH_PATH ?= ../godash

default: help
.PHONY: default

prepare: ## Prepare environment
	dart pub global activate protoc_plugin
	go mod -C go tidy
	go -C go mod download
	go -C go install tool
	$(call PROTO_GO)
	$(call PROTO_DART)
	$(call APPLY_GO_LICENSES)
ifeq ($(wildcard web/.),)
		flutter create -e --platforms=web .
		$(call UPDATE_WEB)
endif
ifeq ($(wildcard android/.),)
		$(call PREPARE_ANDROID)
endif
ifeq ($(wildcard ios/.),)
		$(call PREPARE_IOS)
endif
ifeq ($(wildcard macos/.),)
		$(call PREPARE_MACOS)
endif
.PHONY: prepare

define UPDATE_WEB
	mkdir -p web
	cp -fr platform_templates/web/. web/
endef

prepare_web: ## Prepare Web-only environment
	dart pub global activate protoc_plugin
	go mod -C go tidy
	go -C go mod download
	go -C go install tool
	$(call PROTO_GO)
	$(call PROTO_DART)
ifeq ($(wildcard web/.),)
		flutter create -e --platforms=web .
		$(call UPDATE_WEB)
endif
.PHONY: prepare_web

update_web: ## Update Web
	$(call UPDATE_WEB)
.PHONY: update_web

define PREPARE_ANDROID
	flutter create -e --platforms=android .
	perl -pi -e 's/(<manifest .*?>)/$$1\n    <uses-permission android:name="android.permission.INTERNET" \/>/' android/app/src/main/AndroidManifest.xml;
endef

define PREPARE_IOS
	flutter create -e --platforms=ios .
	perl -pi -e 's/(<\/dict>)/\t<key>com.apple.security.network.client<\/key>\n\t<true\/>\n\t<key>keychain-access-groups<\/key>\n\t<array\/>\n$$1/' ios/Runner/DebugProfile.entitlements
	perl -pi -e 's/(<\/dict>)/\t<key>com.apple.security.network.client<\/key>\n\t<true\/>\n\t<key>keychain-access-groups<\/key>\n\t<array\/>\n$$1/' ios/Runner/Release.entitlements
endef

define PREPARE_MACOS
	flutter create -e --platforms=macos .
	perl -pi -e 's/(<\/dict>)/\t<key>com.apple.security.network.client<\/key>\n\t<true\/>\n\t<key>keychain-access-groups<\/key>\n\t<array\/>\n$$1/' macos/Runner/DebugProfile.entitlements
	perl -pi -e 's/(<\/dict>)/\t<key>com.apple.security.network.client<\/key>\n\t<true\/>\n\t<key>keychain-access-groups<\/key>\n\t<array\/>\n$$1/' macos/Runner/Release.entitlements
endef

define UPDATE_GO_BUILD_VERSION
	go run go/cmd/gen_go_build_version/main.go lib/version/version.dart
endef

define UPDATE_GO_BUILD_VERSION_WEB
	perl -pi -e "s/const asset.*?$$/$$1const asset = \"worker.wasm\?v=$(shell date +%s)\"\;/" web/worker.js
endef

define APPLY_GO_LICENSES
	mkdir -p lib/licenses
	go tool -C go go-licenses report . --template template/licenses_dart.tpl > lib/licenses/licenses.g.dart 2> /dev/null
endef

apply_go_licenses: ## Apply Go licenses to Dart
	$(call APPLY_GO_LICENSES)
.PHONY: apply_go_licenses

prepare_go_wasm_test: web/sqlite3.js web/sqlite3.js web/sqlite3-opfs-async-proxy.js web/sqlite3.wasm  ## Prepare Go Wasm test environment
	cp web/sqlite3.js $(GODASH_PATH)/cmd/go_js_wasm_exec/
	cp web/sqlite3.wasm $(GODASH_PATH)/cmd/go_js_wasm_exec/
	cp web/sqlite3-opfs-async-proxy.js $(GODASH_PATH)/cmd/go_js_wasm_exec/
	cp web/scroll_worker.js $(GODASH_PATH)/cmd/go_js_wasm_exec/
	go install -C $(GODASH_PATH)/cmd/go_js_wasm_exec
.PHONY: prepare_go_wasm_test

web: update_web proto wasm_tinygo apply_go_licenses ## Build for Web browser
	flutter build web --wasm --release
.PHONY: web

web_run: update_web proto wasm ## Run for Web browser
	flutter run -d web-server
.PHONY: web_run

web_run_opt: update_web proto wasm_tinygo ## Run for Web browser optimized
	flutter run -d web-server
.PHONY: web_run_opt

wasm: wasm_exec web/sqlite3.js ## Build Wasm worker
	go mod -C go download
	GOOS=js GOARCH=wasm go build -C go -ldflags='-w -s' -o ../web/worker.wasm
	$(call UPDATE_GO_BUILD_VERSION)
	$(call UPDATE_GO_BUILD_VERSION_WEB)
.PHONY: wasm

wasm_tinygo: wasm_exec_tinygo web/sqlite3.js ## Build Wasm worker with TinyGo
	go mod -C go download
	GOOS=js GOARCH=wasm tinygo build -C go -no-debug -panic=trap -opt=2 -o ../web/worker.wasm
	$(call UPDATE_GO_BUILD_VERSION)
	$(call UPDATE_GO_BUILD_VERSION_WEB)
.PHONY: wasm_tinygo

wasm_exec:
	cp $(shell go env GOROOT)/lib/wasm/wasm_exec.js web/
.PHONY: wasm_exec

wasm_exec_tinygo:
# TINYGOROOT's wasm_exec.js is broken now, so use the patched version
# 	cp $(shell tinygo env TINYGOROOT)/targets/wasm_exec.js web/
	cp tinygo_wasm_exec.js web/wasm_exec.js
.PHONY: wasm_exec_tinygo

web/sqlite3.js:
	curl -L -o /tmp/sqlite-wasm.zip https://sqlite.org/2026/sqlite-wasm-3530300.zip
	unzip -o /tmp/sqlite-wasm.zip -d /tmp/sqlite-wasm
	cp /tmp/sqlite-wasm/sqlite-wasm-3530300/jswasm/sqlite3.js web/sqlite3.js
	cp /tmp/sqlite-wasm/sqlite-wasm-3530300/jswasm/sqlite3.wasm web/sqlite3.wasm
	cp /tmp/sqlite-wasm/sqlite-wasm-3530300/jswasm/sqlite3-opfs-async-proxy.js web/sqlite3-opfs-async-proxy.js
	rm -rf /tmp/sqlite-wasm /tmp/sqlite-wasm.zip

# Native builds (Android / iOS / macOS) require a native bridge plugin.
# See README.md for how to add packages/native_internal or your own plugin.

proto: ## Generate protobuf code
	$(call PROTO_GO)
	$(call PROTO_DART)
.PHONY: proto

proto_go: ## Generate protobuf Go code (for CI)
	$(call PROTO_GO)
.PHONY: proto_go

APP_PROTOS := proto/echo.proto

define PROTO_GO
	go install -C $(GODASH_PATH)/cmd/protoc-gen-go-godash
	# 0. Clean proto gen files
	rm -rf go/pb/*
	mkdir -p go/pb
	# 1. Generate standard Go Protobuf (for non-TinyGo)
	protoc -I=proto -I=$(GODASH_PATH)/proto \
		--plugin protoc-gen-go="$(shell go env GOPATH)/bin/protoc-gen-go" \
		--go_out=go --go_opt=module=flap $(APP_PROTOS)
	# 2. Add build tag to standard Go files
	for f in go/pb/*.pb.go; do \
		if ! grep -q "go:build" $$f; then \
			if [ "$$(uname)" = "Darwin" ]; then \
				sed -i '' '1s/^/\/\/go:build !js\n\n/' $$f; \
			else \
				sed -i '1s/^/\/\/go:build !js\n\n/' $$f; \
			fi \
		fi \
	done
	# 3. Temporarily move standard files to avoid overwrite
	mkdir -p go/pb/tmp_std
	mv go/pb/*.pb.go go/pb/tmp_std/
	# 4. Generate Lite Go Protobuf (for TinyGo) and godash Flap Protobuf
	protoc -I=proto -I=$(GODASH_PATH)/proto \
		--plugin protoc-gen-go-lite="$(shell go env GOPATH)/bin/protoc-gen-go-lite" \
		--plugin protoc-gen-go-godash="$(shell go env GOPATH)/bin/protoc-gen-go-godash" \
		--go-lite_out=go --go-lite_opt=module=flap,features=marshal+unmarshal+size+equal+clone \
		--go-godash_out=go --go-godash_opt=module=flap,core_pkg=github.com/nosuta/godash/pb \
		$(APP_PROTOS)
	# 5. Rename Lite files and add build tag
	for f in go/pb/*.pb.go; do \
		if [ "$$(uname)" = "Darwin" ]; then \
			sed -i '' '1s/^/\/\/go:build js\n\n/' $$f; \
		else \
			sed -i '1s/^/\/\/go:build js\n\n/' $$f; \
		fi; \
		mv $$f $${f%.go}_lite.go; \
	done
	# 6. Restore standard files
	mv go/pb/tmp_std/*.pb.go go/pb/
	rmdir go/pb/tmp_std
	# 7. Generate MarshalVT wrappers for standard Go
	go run -C $(GODASH_PATH) ./cmd/gen_marshal_std $(PWD)/go/pb
endef

define PROTO_DART
	rm -rf lib/pb/*
	mkdir -p lib/pb
	go install -C $(GODASH_PATH)/cmd/protoc-gen-dart-godash
	# 10. Generate Dart code
	protoc -I=proto -I=$(GODASH_PATH)/proto \
		--plugin protoc-gen-dart-godash="$(shell go env GOPATH)/bin/protoc-gen-dart-godash" \
		--dart_out=lib/pb \
		--dart-godash_out=lib/pb \
		$(APP_PROTOS)
endef

clean: ## Clean all build artifacts
	rm -f web/wasm_exec.js
	rm -f web/sqlite3.js
	rm -f web/sqlite3-opfs-async-proxy.js
	rm -f web/sqlite3.wasm
	rm -f $(GODASH_PATH)/cmd/go_js_wasm_exec/sqlite3.js
	rm -f $(GODASH_PATH)/cmd/go_js_wasm_exec/sqlite3-opfs-async-proxy.js
	rm -f $(GODASH_PATH)/cmd/go_js_wasm_exec/sqlite3.wasm
	rm -f $(GODASH_PATH)/cmd/go_js_wasm_exec/wasm_exec.js
	rm -rf go/build/
	rm -rf go/pb/
	rm -rf lib/pb/
	rm -f exported.h
	rm -f lib/version/version.dart
	flutter clean
.PHONY: clean

reset: clean ## Reset the project to template state
	rm -rf web
	rm -rf android
	rm -rf ios
	rm -rf macos
.PHONY: reset

flap: ## Install flap CLI
	go install -C $(GODASH_PATH) -ldflags="-X main.Version=latest" ./cmd/flap
.PHONY: flap

help: ## Show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help
