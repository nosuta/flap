// Benchmark worker shim: loads the Go wasm runtime and runs the benchmark
// worker binary (worker.wasm, built from benchmark/web/worker).
importScripts('wasm_exec.js');

const go = new Go();
go.argv = ['worker'];
go.env = Object.assign({ GOOS: 'js' }, go.env);
go.exit = (code) => {
  if (code !== 0) console.error('worker exited with code', code);
};

WebAssembly.instantiateStreaming(fetch('worker.wasm'), go.importObject)
  .then((result) => {
    go.run(result.instance);
  })
  .catch((err) => {
    console.error('failed to instantiate worker.wasm:', err);
  });
