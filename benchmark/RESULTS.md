# Benchmark results — bridge latency baseline

Latency of one unary echo round trip (`RpcRequest(path, payload)` →
`RpcResponse(same payload)`) through the envelope bridge, measured **before**
any zero-copy / sync-path optimization work (PLAN.md P1+). The echo semantics
mirror the template `EchoServer.Echo` at the envelope level
(`benchmark/bench/bench.go`).

Baseline recorded: 2026-08-28, commit at P0 completion.
Machine: macOS (darwin/arm64, Apple Silicon), Go 1.27, Dart 3.14 dev / Flutter 3.48 master.
Payload: 64 bytes. Native driver uses a fresh `ReceivePort` per call and the
same allocation/free pattern as `lib/bridge/bridge_native.dart`.

## Native (FFI, c-shared libbench → Go)

Unit: microseconds per round trip (n=5000 after 200 warmup).

| metric | value |
|---|---|
| min | 21 µs |
| p50 | 39 µs |
| p90 | 64 µs |
| p99 | 129 µs |
| max | 1070 µs |
| mean | 45.9 µs |

## Web (Go wasm worker, Chrome, postMessage envelope)

Unit: milliseconds per round trip (n=2000 after 200 warmup). Standard Go
wasm (not TinyGo); production release builds use TinyGo, so absolute numbers
differ — treat these as a Go-wasm baseline.

| metric | value |
|---|---|
| min | 0.00 ms |
| p50 | 0.10 ms |
| p90 | 0.20 ms |
| p99 | 0.50 ms |
| max | 14.3 ms |
| mean | 0.124 ms |

## How to reproduce

Native:

```sh
go build -buildmode=c-shared -o benchmark/native/libbench.dylib ./benchmark/native
dart run benchmark/native/bench.dart --n 5000
# flags: --n, --warmup, --payload (bytes), --lib (path to libbench)
```

Web:

```sh
GOOS=js GOARCH=wasm go build -o benchmark/web/worker.wasm ./benchmark/web/worker
cp "$(go env GOROOT)/lib/wasm/wasm_exec.js" benchmark/web/
go run ./benchmark/web/driver --dir benchmark/web --n 2000
# flags: --n, --warmup, --payload (bytes), --dir (page assets dir), --timeout
```

The web page (`benchmark/web/index.html` + `bench.js` + `worker.js`) drives
the real worker protocol: global Done handshake, Init exchange, then one
fresh `MessageChannel` per echo call, timing each round trip with
`performance.now()`.

## Notes

- The measured path includes protobuf `Request.writeToBuffer()` /
  `Response.fromBuffer()` on the Dart side and `MarshalVT`/`UnmarshalVT` on
  the Go side, the `BytesContainer` copy-in, the goroutine spawn and the
  `ReceivePort` round trip — i.e. everything P1 (response zero-copy) and
  P2 (sync FFI unary path) target.
- Native per-call cost breakdown of interest for later phases: the fixed
  goroutine + port overhead (~10 µs, B5) plus serialize/memcpy (B1–B4).
  Re-run this harness after each phase and append a row here.
