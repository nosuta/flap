<p align="center">
<img align="center" awidth="120" height="120" src="https://raw.githubusercontent.com/nosuta/flap/master/art/logo.png"><br>
<b>Go x Flutter frontend template</b>
</p>

# Flap

Build cross-platform Flutter apps with embedded Go.

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

## Acknowledgements

At the early stage of this project, it was heavily influenced by [flutter-openpgp](https://github.com/jerson/flutter-openpgp), which convinced me of the potential of the Go–Flutter bridge.
