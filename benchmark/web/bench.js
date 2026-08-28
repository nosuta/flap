// Web latency benchmark page script.
//
// Drives the godash web worker exactly like lib/bridge/bridge_web.dart:
// - the worker posts a global Done once it is up,
// - each call uses a fresh MessageChannel and posts [port2, view] with
//   transfer list [port2, ab],
// - the response arrives on port1 as a Uint8Array envelope, ending with Done.
//
// Results are exposed as window.__benchResults (JSON) and rendered into
// #results; the chromedp driver (benchmark/web/driver) reads them.
const params = new URLSearchParams(location.search);
const N = Number(params.get('n') ?? 2000);
const WARMUP = Number(params.get('warmup') ?? 200);
const PAYLOAD_SIZE = Number(params.get('payload') ?? 64);
const ECHO_PATH = '/bench.EchoService/Echo';

function makePayload(size) {
  const b = new Uint8Array(size);
  for (let i = 0; i < size; i++) {
    b[i] = i & 0x7F;
  }
  return b;
}

// Envelope request marshaling: this harness hand-encodes the two fields of
// RpcRequest (path=1 string, payload=2 bytes) and Request (rpc_request=10
// message, port=5 varint) to stay dependency-free. Field order follows the
// proto definitions in proto/core.proto.
function encodeVarint(value) {
  const out = [];
  let v = value;
  while (v > 0x7F) {
    out.push((v & 0x7F) | 0x80);
    v = Math.floor(v / 128);
  }
  out.push(v & 0x7F);
  return out;
}

function encodeString(fieldNumber, s) {
  const bytes = Array.from(new TextEncoder().encode(s));
  return [...encodeVarint((fieldNumber << 3) | 2), ...encodeVarint(bytes.length), ...bytes];
}

function encodeBytes(fieldNumber, bytes) {
  return [...encodeVarint((fieldNumber << 3) | 2), ...encodeVarint(bytes.length), ...bytes];
}

function encodeEchoRequest(port, payload) {
  const rpcRequest = [...encodeString(1, ECHO_PATH), ...encodeBytes(2, payload)];
  return new Uint8Array([
    ...encodeVarint((10 << 3) | 2), ...encodeVarint(rpcRequest.length), ...rpcRequest,
    ...encodeVarint((5 << 3) | 0), ...encodeVarint(port),
  ]);
}

// rpcOnce mirrors Bridge.rpcUnsafe: fresh MessageChannel per call, resolve on
// the first response envelope, ignore the trailing Done.
function rpcOnce(worker, requestBytes) {
  return new Promise((resolve, reject) => {
    const ch = new MessageChannel();
    const responses = [];
    ch.port1.onmessage = (message) => {
      const data = message.data;
      if (!data) {
        reject(new Error('rpc response data is null'));
        return;
      }
      responses.push(data);
      // Resolve on the first message; the worker then posts Done which we
      // simply let arrive before closing the ports below.
      resolve(responses[0]);
      setTimeout(() => {
        ch.port2.close();
        ch.port1.close();
      }, 0);
    };
    const ab = new ArrayBuffer(requestBytes.length);
    const view = new Uint8Array(ab);
    view.set(requestBytes);
    worker.postMessage([ch.port2, view], [ch.port2, ab]);
  });
}

function percentile(sorted, p) {
  const idx = Math.round(p * (sorted.length - 1));
  return sorted[Math.min(Math.max(idx, 0), sorted.length - 1)];
}

async function main() {
  const payload = makePayload(PAYLOAD_SIZE);
  let nextPort = 1;
  const worker = new Worker('worker.js');
  await new Promise((resolve, reject) => {
    worker.onerror = (e) => reject(new Error('worker error: ' + e.message));
    const timer = setTimeout(() => reject(new Error('worker startup timeout')), 30000);
    worker.onmessage = (e) => {
      clearTimeout(timer);
      resolve(e.data);
    };
  });

  // Warmup.
  for (let i = 0; i < WARMUP; i++) {
    await rpcOnce(worker, encodeEchoRequest(nextPort++, payload));
  }

  const times = [];
  for (let i = 0; i < N; i++) {
    const bytes = encodeEchoRequest(nextPort++, payload);
    const t0 = performance.now();
    const resp = await rpcOnce(worker, bytes);
    const t1 = performance.now();
    times.push(t1 - t0);
    if (resp.length === 0) {
      throw new Error('empty response at iteration ' + i);
    }
  }

  times.sort((a, b) => a - b);
  const mean = times.reduce((a, b) => a + b, 0) / times.length;
  const stats = {
    transport: 'web',
    iterations: N,
    warmup: WARMUP,
    payload_bytes: PAYLOAD_SIZE,
    unit: 'ms',
    min: times[0],
    p50: percentile(times, 0.50),
    p90: percentile(times, 0.90),
    p99: percentile(times, 0.99),
    max: times[times.length - 1],
    mean: mean,
  };
  window.__benchResults = stats;
  document.getElementById('results').textContent = JSON.stringify(stats, null, 2);
  document.getElementById('doneButton').style.display = 'block';
}

main().catch((e) => {
  document.getElementById('results').textContent = 'ERROR: ' + (e && e.message ? e.message : e);
  window.__benchResults = { error: String(e && e.message ? e.message : e) };
  document.getElementById('doneButton').style.display = 'block';
});
