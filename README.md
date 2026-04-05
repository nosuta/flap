<p align="center">
<img align="center" height="120" src="https://raw.githubusercontent.com/nosuta/flap/master/art/logo.png"><br>
<b>Go inside Flutter</b>
</p>

# Flap

Flap is a template project that enables seamless integration of Go code into Flutter applications. It allows you to compile Go code directly into your Flutter app, providing high-performance native functionality across multiple platforms.

## Features

- **Cross-platform support**: Web, Android, and iOS
- **RPC communication**: Bidirectional RPC between Dart and Go
- **Push notifications**: One-way push messages from Go to Dart
- **Protocol Buffers**: Efficient serialization with protobuf
- **SQLite integration**: Built-in SQLite support for data persistence
- **WebAssembly**: Web platform support via TinyGo and WebAssembly

## Supported Platforms

- 🌐 Web (using TinyGo and WebAssembly)
- 🤖 Android
- 🍎 iOS

## Quick Start

### Using the CLI (Recommended)

1. Install the Flap CLI:
   ```sh
   brew install nosuta/flap/flap
   ```

2. Create a new project:
   ```sh
   flap
   ```
   This will check dependencies, prompt for your app name and bundle ID, clone the template, and run the full setup automatically.

### Manual Setup

#### Prerequisites

- Go 1.25.0 or later
- Flutter 3.10.0 or later
- Protocol Buffers compiler (`protoc`)
- Perl
- npm (for Web development)
- TinyGo (for Web platform)
- Chrome (for Web testing)

#### Setup Steps

1. Clone this repository:
   ```sh
   git clone https://github.com/nosuta/flap.git
   cd flap
   ```

2. Create custom configuration:
   ```sh
   cp template.mk custom.mk
   ```
   Edit `custom.mk` to fill in your environment variables.

3. Prepare the project:
   ```sh
   make prepare
   ```

4. For Web development, prepare WebAssembly testing:
   ```sh
   make prepare_go_wasm_test
   ```

## Usage

### Running the App

Run on different platforms:

```sh
# Web
make web_run

See all available commands:
```sh
make help
```

### Defining RPC Services

Flap uses Protocol Buffers to define RPC services between Dart and Go. The code generators use service name suffixes to determine what code to emit.

#### Standard RPC (Dart → Go → Dart)

Services ending with `Service` generate standard RPC clients:

```proto
service NostrService {
  rpc FetchNotes(NotesRequest) returns (stream Note);
}
```

| Side | Generated Code                                          |
| ---- | ------------------------------------------------------- |
| Dart | `NostrRpcClient` — Call Go from Dart                    |
| Go   | `NostrRPCHandler` interface + `HandleNostrRPC()` router |

#### Reverse RPC (Go → Dart → Go)

Services ending with `ReverseService` generate reverse RPC where Go calls Dart:

```proto
service NostrReverseService {
  rpc Nip07SignEvent(Nip07SignEventRequest) returns (Nip07SignEventResponse);
}
```

| Side | Generated Code                                                  |
| ---- | --------------------------------------------------------------- |
| Dart | `NostrReverseRpc` abstract class — Extend and implement methods |
| Go   | `NostrReverseRPCNip07SignEvent(ctx, req)` caller function       |

#### Push Messages (Go → Dart)

Messages starting with `Push` are one-way notifications:

```proto
message PushNip05 { ... }
```

| Side | Generated Code                                 |
| ---- | ---------------------------------------------- |
| Dart | `PushHandler` — Typed streams per message type |
| Go   | `SendPushNip05(msg)` pusher function           |

## Development

### Updating from Template

If you started from this template, you can pull in updates:

```sh
git fetch upstream
git merge upstream/master
```

## Acknowledgements

At the early stage of this project, it was heavily influenced by [flutter-openpgp](https://github.com/jerson/flutter-openpgp), which convinced me of the potential of the Go–Flutter bridge.
