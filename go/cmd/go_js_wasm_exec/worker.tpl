"use strict";

importScripts("wasm_exec.js");
importScripts("sqlite3.js");

if (!WebAssembly.instantiateStreaming) { // polyfill
    WebAssembly.instantiateStreaming = async (resp, importObject) => {
        const source = await (await resp).arrayBuffer();
        return await WebAssembly.instantiate(source, importObject);
    };
}

let exitCode = 0;
function goExit(code) {
    exitCode = code;
}
const securityToken = "{{.SecurityToken}}";
const fsPath = "/fs";
function fsHandler(name, body, onOk, onErr) {
    const url = fsPath + "/" + name;
    const options = {
        method: "POST",
        body: JSON.stringify(body), headers: {"WBT-Token": securityToken }
    };
    fetch(url, options).then(res => res.json()).then(payload => {
        if (payload.error) {
            const err = new Error(payload.error);
            err.code = payload.code;
            onErr(err);
        } else {
            onOk(payload);
        }
    }).catch((fetchError) => {
        console.log("fetch error", fetchError)
        const err = new Error("bad server response");
        err.code = "ENOSYS";
        onErr(err);
    })
}
function bufferToBase64(buf) {
    let binaryString = "";
    let bytes = new Uint8Array(buf);
    const len = bytes.length;
    for (let i = 0; i < len; i++) {
        binaryString += String.fromCharCode(bytes[i]);
    }
    return btoa(binaryString);
}
function overrideProcess(process) {
    // provide non-negative pid so counter file regex matches
    // https://github.com/golang/go/blob/9a49b26bdf771ecdfa2d3bc3ee5175eed5321f20/src/internal/coverage/defs.go#L327
    process.pid = {{.Pid}};
    process.ppid = {{.Ppid}};
    process.cwd = () => { return fsPath };
}
// Prepending /fs/ prevents jsProcess.Call("cwd") for windows drive letter paths.
// https://github.com/golang/go/blob/5a9b6432ec8b9199ce9fce9387e94195138b313f/src/syscall/fs_js.go#L104
// This prefix is removed by filesys/handler.go fixPath() in each api call.
function fsp(path) {
    return fsPath + "/" + path;
}
function overrideFS(fs) {
    // The fs.constants are read at https://github.com/golang/go/blob/8071f2a1697c2a8d7e93fb1f45285f18303ddc76/src/syscall/fs_js.go#L25
    // These values are pulled from https://github.com/golang/go/blob/8071f2a1697c2a8d7e93fb1f45285f18303ddc76/src/syscall/syscall_js.go#L126
    fs.constants = { O_WRONLY: 1, O_RDWR: 2,
        O_CREAT: 0o100, O_TRUNC: 0o1000, O_APPEND: 0o2000, O_EXCL: 0o200, O_DIRECTORY: 0o20000 };
    fs.open = (path, flags, mode, callback) => {
        fsHandler("open", { path: fsp(path), flags, mode }, (resp) => callback(null, resp.fd), callback);
    };
    fs.close = (fd, callback) => {
        fsHandler("close", { fd }, () => callback(null), callback);
    };
    const defaultWrite = fs.write.bind(fs);
    fs.write = (fd, buf, offset, length, position, callback) => {
        // stdin=0, stdout=1, stderr=2
        if (fd < 3) {
            defaultWrite(fd, buf, offset, length, position, callback);
            return;
        }
        const buffer = bufferToBase64(buf);
        fsHandler("write", {fd, buffer, offset, length, position}, (resp) => {
            callback(null, resp.written);
        }, callback);
    };
    fs.stat = (path, callback) => {
        fsHandler("stat", { path: fsp(path) }, (resp) => callback(null, resp), callback);
    };
    fs.fstat = (fd, callback) => {
        fsHandler("fstat", { fd }, (resp) => {
            // for https://github.com/golang/go/blob/c19c4c566c63818dfd059b352e52c4710eecf14d/src/syscall/fs_js.go#L93
            resp.isDirectory = () => {
                return (resp.mode & (1 << 14)) > 0
            }
            callback(null, resp);
        }, callback);
    };
    fs.rename = (from, to, callback) => {
        fsHandler("rename", { from: fsp(from), to: fsp(to) }, () => callback(null), callback);
    };
    fs.readdir = (path, callback) => {
        fsHandler("readdir", { path: fsp(path) }, (resp) => callback(null, resp.entries), callback);
    };
    fs.lstat = (path, callback) => {
        fsHandler("lstat", { path: fsp(path) }, (resp) => callback(null, resp), callback);
    };
    fs.read = (fd, buffer, offset, length, position, callback) => {
        fsHandler("read", { fd, offset, length, position }, (resp) => {
            const binaryString = atob(resp.buffer);
            for (let i = 0; i < binaryString.length; i++) {
                buffer[i] = binaryString.charCodeAt(i);
            }
            callback(null, resp.read);
        }, callback);
    };
    fs.mkdir = (path, perm, callback) => {
        fsHandler("mkdir", { path: fsp(path), perm }, () => callback(null), callback);
    };
    fs.unlink = (path, callback) => {
        fsHandler("unlink", { path: fsp(path) }, () => callback(null), callback);
    };
    fs.rmdir = (path, callback) => {
        fsHandler("rmdir", { path: fsp(path) }, () => callback(null), callback);
    };
}

(async() => {
    const go = new self.Go();
    overrideFS(self.fs);
    overrideProcess(self.process);
    go.argv = [{{range $i, $item:= .Args}} {{if $i}}, {{end}} "{{$item}}" {{end}}];
    // The notFirst variable sets itself to true after first iteration. This is to put commas in between.
    go.env = { {{$notFirst := false}}
    {{range $key, $val:= .EnvMap}} {{if $notFirst}}, {{end}} {{$key}}: "{{$val}}" {{$notFirst = true}}
    {{end}} };
    go.exit = goExit;
    const {instance} = await WebAssembly.instantiateStreaming(fetch("{{.WASMFile}}"), go.importObject).catch((e) => {
        postMessage({type: "exception", msg: e});
    });
    await go.run(instance).catch((e) => {
        exitCode = 1;
        postMessage({type: "exception", msg: e});
    });
    postMessage({type: "done", exitCode: exitCode});
})();
