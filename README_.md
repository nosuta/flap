<p align="center">
<img align="center" awidth="150" height="150" src="https://raw.githubusercontent.com/nosuta/flap/master/art/logo.png"><br>
<b>Go x Flutter frontend template</b>
</p>

# Flap (WIP)

Build cross-platform Flutter apps with embedded Go.

## Supported platforms

- Web
- Android
- iOS
- macOS

## Build

### Prerequisites

- Go
- Flutter
- protoc
- perl
- npm (for Web)
- TinyGo (for Web)

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

## Acknowledgements

At the early stage of this project, it was heavily influenced by [flutter-openpgp](https://github.com/jerson/flutter-openpgp), which convinced me of the potential of the Go–Flutter bridge.
