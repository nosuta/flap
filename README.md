<p align="center">
<img align="center" awidth="120" height="120" src="https://raw.githubusercontent.com/nosuta/flap/master/art/logo.png"><br>
<b>Go inside Flutter</b>
</p>

# Flap

The template for Go compiled into your Flutter app.

## Supported platforms

- Web
- Android
- iOS
- macOS

## Getting Started

Install the CLI from [GitHub Releases](https://github.com/nosuta/flap/releases/latest).

Create a new project:

```sh
flap
```

This checks dependencies, prompts for your app name and bundle ID, clones the template, and runs the full setup automatically.

### Updating from the template

The template is set as the `upstream` remote. To pull in updates:

```sh
git fetch upstream
git merge upstream/master
```

## Manual setup (without CLI)

### Prerequisites

- Go
- Flutter
- protoc
- perl
- npm (for Web)
- TinyGo (for Web)
- Chrome (for Web)

### Setup

Create `custom.mk` from `template.mk` then fill the environments:

```sh
cp template.mk custom.mk
```

Prepare:

```sh
make prepare
```

Prepare for Web testing:

```sh
make prepare_go_wasm_test
```

### Run

Run the Web app:

```sh
make web_run
```

Other options:

```sh
make help
```

## Defining RPC services in proto

The code generators (`protoc-gen-go-flap` and `protoc-gen-dart-flap`) use service name suffixes to determine what code to emit.

### `XxxService` — Dart → Go → Dart RPC

A service whose name ends with `Service` (but not `ReverseService`) generates a standard RPC client on the Dart side and a handler interface on the Go side.

```proto
service NostrService {
  rpc FetchNotes(NotesRequest) returns (stream Note);
}
```

| Side | Generated |
|------|-----------|
| Dart | `NostrRpcClient` — call Go from Dart |
| Go   | `NostrRPCHandler` interface + `HandleNostrRPC()` router |

### `XxxReverseService` — Go → Dart → Go RPC

A service whose name ends with `ReverseService` generates a reverse RPC: Go calls Dart and waits for a response.

```proto
service NostrReverseService {
  rpc Nip07SignEvent(Nip07SignEventRequest) returns (Nip07SignEventResponse);
}
```

| Side | Generated |
|------|-----------|
| Dart | `NostrReverseRpc` abstract class — extend and implement the methods |
| Go   | `NostrReverseRPCNip07SignEvent(ctx, req)` caller function |

Instantiating the Dart subclass is all that is needed — it self-registers and starts listening automatically.

### Push messages — Go → Dart (fire-and-forget)

Messages whose name starts with `Push` (e.g. `PushNip05`) are treated as one-way push notifications from Go to Dart. No response is sent back.

```proto
message PushNip05 { ... }
```

| Side | Generated |
|------|-----------|
| Dart | `PushHandler` — typed streams per message type (e.g. `.nip05`) |
| Go   | `SendPushNip05(msg)` pusher function |

## Acknowledgements

At the early stage of this project, it was heavily influenced by [flutter-openpgp](https://github.com/jerson/flutter-openpgp), which convinced me of the potential of the Go–Flutter bridge.
