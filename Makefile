# NOT RECOMMENDED TO EDIT

-include custom.mk

include core.env

default: help
.PHONY: default

prepare: ## Prepare environment
	dart pub global activate protoc_plugin
	go mod -C go tidy
	$(call PROTO_GO)
	$(call PROTO_DART)
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

update_web: ## Update Web
	$(call UPDATE_WEB)
.PHONY: update_web

define PREPARE_ANDROID
	flutter create -e --platforms=android .
	perl -pi -e 's/(<manifest .*?>)/$$1\n    <uses-permission android:name="android.permission.INTERNET" \/>/' android/app/src/main/AndroidManifest.xml;
endef

define PREPARE_IOS
	flutter create -e --platforms=ios .
endef

define PREPARE_MACOS
	flutter create -e --platforms=macos .
	perl -pi -e 's/(<\/dict>)/\t<key>com.apple.security.network.client<\/key>\n\t<true\/>\n\t<key>keychain-access-groups<\/key>\n\t<array\/>\n$$1/' macos/Runner/DebugProfile.entitlements
	perl -pi -e 's/(<\/dict>)/\t<key>com.apple.security.network.client<\/key>\n\t<true\/>\n\t<key>keychain-access-groups<\/key>\n\t<array\/>\n$$1/' macos/Runner/Release.entitlements
endef

define UPDATE_GO_BUILD_VERSION
	perl -pi -e "s/static const.*?$$/$$1static const String version = '$(shell date +%s)'\;/" lib/version/go_build_version.dart
endef

define UPDATE_GO_BUILD_VERSION_WEB
	perl -pi -e "s/const asset.*?$$/$$1const asset = \"assets\/packages\/web_internal\/worker.wasm\?v=$(shell date +%s)\"\;/" web/worker.js
endef

prepare_go_wasm_test: web/sqlite3.js web/sqlite3.js web/sqlite3-opfs-async-proxy.js web/sqlite3.wasm ## Prepare Go wasm test
	cp web/sqlite3.js go/cmd/go_js_wasm_exec/
	cp web/sqlite3.wasm go/cmd/go_js_wasm_exec/
	cp web/sqlite3-opfs-async-proxy.js go/cmd/go_js_wasm_exec/
	go install -C go/cmd/go_js_wasm_exec
.PHONY: prepare_go_wasm_test

web: update_web proto wasm_tinygo ## Build for Web browser
	flutter build web --wasm --release
.PHONY: web

web_publish: web ## Publish (remove this and /public before the flap release)
	rm -rf public/*
	cp -r build/web/* public
.PHONY: web_publish

web_run: update_web proto wasm ## Run for Web browser
	flutter run -d web-server
.PHONY: web_run

web_run_opt: update_web proto wasm_tinygo ## Run for Web browser optimized
	flutter run -d web-server
.PHONY: web_run_opt

wasm: wasm_exec web/sqlite3.js ## Build Wasm worker
	GOOS=js GOARCH=wasm go build -C go -ldflags='-w -s' -o ../packages/web_internal/lib/worker.wasm
	$(call UPDATE_GO_BUILD_VERSION)
	$(call UPDATE_GO_BUILD_VERSION_WEB)
.PHONY: wasm

wasm_tinygo: wasm_exec_tinygo web/sqlite3.js ## Build Wasm worker with TinyGo
	GOOS=js GOARCH=wasm tinygo build -C go -no-debug -panic=trap -opt=2 -o ../packages/web_internal/lib/worker.wasm
	$(call UPDATE_GO_BUILD_VERSION)
	$(call UPDATE_GO_BUILD_VERSION_WEB)
.PHONY: wasm_tinygo

wasm_exec:
	cp $(shell go env GOROOT)/lib/wasm/wasm_exec.js web/
.PHONY: wasm_exec

wasm_exec_tinygo:
	cp $(shell tinygo env TINYGOROOT)/targets/wasm_exec.js web/
.PHONY: wasm_exec_tinygo

web/sqlite3.js:
	npm install @sqlite.org/sqlite-wasm@">=3.51.1-build1"
	cp node_modules/@sqlite.org/sqlite-wasm/sqlite-wasm/jswasm/sqlite3-opfs-async-proxy.js web/sqlite3-opfs-async-proxy.js
	cp node_modules/@sqlite.org/sqlite-wasm/sqlite-wasm/jswasm/sqlite3.wasm web/sqlite3.wasm
	cp node_modules/@sqlite.org/sqlite-wasm/sqlite-wasm/jswasm/sqlite3.js web/sqlite3.js

apk: proto android_lib_arm64-v8a android_lib_x86_64 ffi ## Build Android apk
	flutter build apk --release --dart-define-from-file=core.env
.PHONY: apk

appbundle: proto android_lib_arm64-v8a android_lib_x86_64 ffi ## Build Android appbundle
	flutter build appbundle --release --dart-define-from-file=core.env
.PHONY: appbundle

NDK_TOOLCHAIN=${NDK_PATH}/toolchains/llvm/prebuilt/darwin-x86_64/bin

android_lib_arm64-v8a: go/dart_api/dart_api_dl.h ## Build Android arm64-v8a library
	CGO_ENABLED=1 GOOS=android GOARCH=arm64 \
	CC=$(NDK_TOOLCHAIN)/aarch64-linux-android21-clang \
	go build -C go -ldflags="-w -s -extldflags=-Wl,-soname,${LIB_NAME}" -buildmode=c-shared -tags='android' \
	-o build/android-arm64-v8a/${LIB_NAME}.so .
	mkdir -p packages/native_internal/android/src/main/jniLibs/arm64-v8a
	cp go/build/android-arm64-v8a/${LIB_NAME}.so packages/native_internal/android/src/main/jniLibs/arm64-v8a/
	cp go/build/android-arm64-v8a/${LIB_NAME}.h exported.h
.PHONY: android_lib_arm64-v8a

android_lib_x86_64: go/dart_api/dart_api_dl.h ## Build Android x86_64 library
	CGO_ENABLED=1 GOOS=android GOARCH=amd64 \
	CC=$(NDK_TOOLCHAIN)/x86_64-linux-android21-clang \
	go build -C go -ldflags="-w -s -extldflags=-Wl,-soname,${LIB_NAME}" -buildmode=c-shared -tags='android' \
	-o build/android-x86_64/${LIB_NAME}.so .
	mkdir -p packages/native_internal/android/src/main/jniLibs/x86_64
	cp go/build/android-x86_64/${LIB_NAME}.so packages/native_internal/android/src/main/jniLibs/x86_64/
	cp go/build/android-x86_64/${LIB_NAME}.h exported.h
.PHONY: android_lib_x86_64

ios: proto ios_lib ffi ## Build for iOS
	flutter build ios --release --dart-define-from-file=core.env
.PHONY: ios

ios_lib: go/dart_api/dart_api_dl.h ## Build iOS native library
	CGO_ENABLED=1 GOOS=ios GOARCH=arm64 CGO_CFLAGS="-fembed-bitcode" \
	SDK=iphoneos PLATFORM=ios CC=$(PWD)/clangwrap.sh \
	go build -C go -buildmode=c-archive -tags='ios' \
	-o build/ios-arm64/${LIB_NAME}.a .
	cp go/build/ios-arm64/${LIB_NAME}.a packages/native_internal/ios/
	cp go/build/ios-arm64/${LIB_NAME}.h exported.h
.PHONY: ios_lib

macos_run: proto macos_lib ffi  ## Run for macOS (test purpose)
	flutter run -d macos --dart-define-from-file=core.env
.PHONY: macos

macos_lib: go/dart_api/dart_api_dl.h ## Build macOS native library (test purpose)
	CGO_ENABLED=1 GOOS=darwin GOARCH=arm64 \
	go build -C go -ldflags='-w -s' -buildmode=c-shared \
	-o build/macos-arm64/${LIB_NAME}.dylib -trimpath .
	cp go/build/macos-arm64/${LIB_NAME}.dylib packages/native_internal/macos/
	cp go/build/macos-arm64/${LIB_NAME}.dylib macos/
	cp go/build/macos-arm64/${LIB_NAME}.h exported.h
.PHONY: macos_lib

go/dart_api/dart_api_dl.h:
	$(call DART_API)

dart_api: ## Update Dart C API headers
	$(call DART_API)
.PHONY: dart_api

define DART_API
	git clone --depth 1 --branch stable https://github.com/dart-lang/sdk /tmp/github.com/dart-lang/sdk
	cp -r /tmp/github.com/dart-lang/sdk/runtime/include/* go/dart_api/
	cp /tmp/github.com/dart-lang/sdk/LICENSE go/dart_api/
	rm -rf /tmp/github.com/dart-lang/sdk
endef

lib/bridge/native_library.g.dart: exported.h
	$(call NATIVE_BRIDGE)

ffi: exported.h ## Generate Dart native bridge
	$(call NATIVE_BRIDGE)
.PHONY: ffi

define NATIVE_BRIDGE
	dart run ffigen --config ffigen_config.yaml --verbose severe && flutter pub get
endef

proto: ## Generate protobuf code
	$(call PROTO_GO)
	$(call PROTO_DART)
.PHONY: proto

proto_go: ## Generate protobuf Go code
	$(call PROTO_GO)
.PHONY: proto_go

define PROTO_GO
	go install -C go/cmd/protoc-gen-flap-go-connect
	# 0. Clean proto gen files
	rm -rf go/pb/*
	mkdir -p go/pb
	# 1. Generate standard Go Protobuf and Connect-Go (for non-JS)
	protoc -I=proto \
		--plugin protoc-gen-go="$(shell go tool -C go -n protoc-gen-go)" \
		--go_out=go --go_opt=module=flap **/*.proto
	protoc -I=proto \
		--plugin protoc-gen-connect-go="$(shell go tool -C go -n protoc-gen-connect-go)" \
		--connect-go_out=go --connect-go_opt=module=flap,paths=import \
		proto/echo.proto
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
	# 3. Add build tag to Connect-Go files
	for f in go/pb/pbconnect/*.connect.go; do \
		if ! grep -q "go:build" $$f; then \
			if [ "$$(uname)" = "Darwin" ]; then \
				sed -i '' '1s/^/\/\/go:build !js\n\n/' $$f; \
			else \
				sed -i '1s/^/\/\/go:build !js\n\n/' $$f; \
			fi \
		fi \
	done
	# 4. Temporarily move standard files to avoid overwrite
	mkdir -p go/pb/tmp_std
	mv go/pb/*.pb.go go/pb/tmp_std/
	# 5. Generate Lite Go Protobuf (for JS/TinyGo)
	protoc -I=proto \
		--plugin protoc-gen-go-lite="$(shell go tool -C go -n protoc-gen-go-lite)" \
		--plugin protoc-gen-flap-go-connect="$(shell go env GOPATH)/bin/protoc-gen-flap-go-connect" \
		--go-lite_out=go --go-lite_opt=module=flap,features=marshal+unmarshal+size+equal+clone \
		--flap-go-connect_out=go --flap-go-connect_opt=module=flap \
		**/*.proto
	# 6. Rename Lite files and add build tag
	for f in go/pb/*.pb.go; do \
		if [ "$$(uname)" = "Darwin" ]; then \
			sed -i '' '1s/^/\/\/go:build js\n\n/' $$f; \
		else \
			sed -i '1s/^/\/\/go:build js\n\n/' $$f; \
		fi; \
		mv $$f $${f%.go}_lite.go; \
	done
	# 8. Restore standard files
	mv go/pb/tmp_std/*.pb.go go/pb/
	rmdir go/pb/tmp_std
	# 9. Generate MarshalVT wrappers for standard Go
	go run go/cmd/gen_marshal_std/main.go go/pb
endef

define PROTO_DART
	rm -rf lib/pb/*
	mkdir -p lib/pb
	go install -C go/cmd/protoc-gen-flap-dart-connect
	# 10. Generate Dart code
	protoc -I=proto \
		--plugin protoc-gen-flap-dart-connect="$(shell go env GOPATH)/bin/protoc-gen-flap-dart-connect" \
		--dart_out=lib/pb \
		--flap-dart-connect_out=lib/pb \
		**/*.proto
endef

clean: ## Clean all build artifacts
	rm -f web/wasm_exec.js
	rm -f web/sqlite3.js
	rm -f web/sqlite3-opfs-async-proxy.js
	rm -f web/sqlite3.wasm
	rm -f go/cmd/go_js_wasm_exec/sqlite3.js
	rm -f go/cmd/go_js_wasm_exec/sqlite3-opfs-async-proxy.js
	rm -f go/cmd/go_js_wasm_exec/sqlite3.wasm
	rm -rf node_modules
	rm -rf public/*
	rm -rf go/pb/*
	rm -rf lib/pb/*
	rm -f packages/native_internal/macos/${LIB_NAME}.dylib
	rm -f macos/${LIB_NAME}.dylib
	rm -f packages/native_internal/ios/${LIB_NAME}.a
	rm -f packages/native_internal/android/src/main/jniLibs/x86_64/${LIB_NAME}.so
	rm -f packages/native_internal/android/src/main/jniLibs/arm64-v8a/${LIB_NAME}.so
	rm -f exported.h
	rm -f lib/bridge/*.g.dart
	flutter clean
.PHONY: clean

action: ## Test GitHub Action locally
	act -s GITHUB_TOKEN="$(shell gh auth token)" --container-architecture linux/amd64
.PHONY: action

help: ## Show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help
