# godash starter

A minimal Flutter + Go/TinyGo project template powered by [godash](https://github.com/nosuta/godash).

## What is included

- Web-first build (`make web`, `make web_run`)
- A single `EchoService` RPC example using godash's Bridge/Transport
- Protobuf code generation wired to `godash`'s custom generators
- TinyGo WASM worker build

## What is NOT included

- Native (Android / iOS / macOS) bridge plugin. To build for native platforms,
  add a Flutter plugin such as `packages/native_internal` that bundles the
  Go c-shared / c-archive library and exposes it via FFI.

## Directory layout

```
.
├── Makefile              # build orchestration
├── core.env              # runtime environment values
├── pubspec.yaml          # Flutter dependencies (uses godash from sibling path)
├── proto/                # app-specific protobuf definitions
│   └── echo.proto
├── go/                   # Go entrypoint and RPC handlers
│   ├── main.go
│   ├── main_js.go
│   ├── rpc/
│   │   ├── rpc_handler.go
│   │   ├── echo_server.go
│   │   └── entrypoint.go
│   └── cmd/gen_go_build_version/
├── lib/                  # Flutter entrypoint and generated protobuf code
│   ├── main.dart
│   └── pb/
└── platform_templates/web/
    └── web worker template files
```

## Quick start

```sh
# 1. Make sure godash is cloned next to this project (or adjust GODASH_PATH).
# 2. Prepare the environment and generate code.
make prepare

# 3. Run in the browser.
make web_run
```

## Generating a new project from this template

Use the `flap` CLI from the `godash` repository:

```sh
# Install flap
go install github.com/nosuta/godash/cmd/flap@latest

# Create a new project
flap
```

By default `flap` clones the published `godash-starter` template. To test
against a local copy, set the `FLAP_TEMPLATE` environment variable:

```sh
FLAP_TEMPLATE=/path/to/godash/template flap
```
