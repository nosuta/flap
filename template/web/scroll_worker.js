// Placeholder scroll worker. Apps that need to offload long synchronous work
// in a worker can replace this file before running `make prepare_go_wasm_test`.
// The Go wasm test runner (`go_js_wasm_exec`) will serve this file at
// /scroll_worker.js when the browser requests it.
self.onmessage = function (e) {
  // echo back
  self.postMessage(e.data);
};
