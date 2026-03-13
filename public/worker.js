"use strict";

"use strict";

importScripts("wasm_exec.js");
importScripts("sqlite3.js");

if (WebAssembly == null || WebAssembly == undefined) {
    console.error("WebAssembly is not supported");
    postMessage(undefined);
}

if (!WebAssembly.instantiateStreaming) {
    WebAssembly.instantiateStreaming = async (resp, importObject) => {
        const source = await (await resp).arrayBuffer().catch((e) => {
            console.error(e);
            postMessage(undefined);
        });
        return await WebAssembly.instantiate(source, importObject).catch((e) => {
            console.error(e);
            postMessage(undefined);
        });
    };
}

(async () => {
    const go = new self.Go();
    const asset = "assets/packages/web_internal/worker.wasm?v=1773062207";
    const { instance } = await WebAssembly.instantiateStreaming(fetch(asset), go.importObject).catch((e) => {
        console.error(e);
        postMessage(undefined);
    });
    await go.run(instance).catch((e) => {
        console.error(e);
        postMessage(undefined);
    });
})();
