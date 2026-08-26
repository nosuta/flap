"use strict";

const baseUrl = self.location.href.substring(0, self.location.href.lastIndexOf('/') + 1);

globalThis.sqlite3InitModuleState = {
    sqlite3Dir: baseUrl
};

try {
    importScripts(baseUrl + "wasm_exec.js");
    console.log("wasm_exec.js loaded");
} catch (e) {
    console.error("Failed to load wasm_exec.js:", e);
    postMessage(undefined);
}

try {
    importScripts(baseUrl + "sqlite3.js");
    console.log("sqlite3.js loaded");
} catch (e) {
    console.error("Failed to load sqlite3.js:", e);
    postMessage(undefined);
}

console.log("worker.js loaded");

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
    const asset = "worker.wasm";
    const { instance } = await WebAssembly.instantiateStreaming(fetch(asset), go.importObject).catch((e) => {
        console.error(e);
        postMessage(undefined);
    });
    await go.run(instance).catch((e) => {
        console.error(e);
        postMessage(undefined);
    });
})();
