// Package assets embeds the web platform assets, patched wasm_exec.js,
// scroll worker placeholder, and licenses template so the godash CLI can
// materialise them in a project without vendoring them in the template tree.
package assets

import (
	"embed"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
)

//go:embed web/*
var webFS embed.FS

//go:embed tinygo_wasm_exec.js
var tinygoWasmExecJS []byte

//go:embed scroll_worker.js
var scrollWorkerJS []byte

// ScrollWorkerJS returns the embedded scroll_worker.js content.
func ScrollWorkerJS() []byte { return scrollWorkerJS }

//go:embed licenses_dart.tpl
var licensesTpl []byte

// AppTitlePlaceholder is the template variable replaced in web/index.html
// when godash extracts it into a project.
const AppTitlePlaceholder = "{{APP_TITLE}}"

// ExtractWeb writes the embedded web/* assets into <projectRoot>/web/.
// The index.html title/meta placeholders ({{APP_TITLE}}) are replaced with
// appTitle. Any pre-existing files at the destination are overwritten —
// these are godash-owned files; user customisation lives in the Flutter
// app itself, not the host page.
func ExtractWeb(projectRoot, appTitle string) error {
	dst := filepath.Join(projectRoot, "web")
	if err := os.MkdirAll(dst, 0755); err != nil {
		return err
	}
	entries, err := webFS.ReadDir("web")
	if err != nil {
		return err
	}
	for _, e := range entries {
		if err := extractFSFile(webFS, "web", e.Name(), filepath.Join(dst, e.Name()), appTitle); err != nil {
			return err
		}
	}
	return nil
}

// WriteTinygoWasmExec writes the patched wasm_exec.js (for TinyGo builds)
// to <projectRoot>/web/wasm_exec.js.
func WriteTinygoWasmExec(projectRoot string) error {
	return os.WriteFile(filepath.Join(projectRoot, "web", "wasm_exec.js"), tinygoWasmExecJS, 0644)
}

// WriteScrollWorker writes the scroll_worker.js placeholder to
// <projectRoot>/web/scroll_worker.js.
func WriteScrollWorker(projectRoot string) error {
	return os.WriteFile(filepath.Join(projectRoot, "web", "scroll_worker.js"), scrollWorkerJS, 0644)
}

// WriteLicensesTempFile writes the embedded licenses_dart.tpl to a temp
// file (so the go-licenses tool can read it via --template) and returns the
// path. The caller is responsible for removing the file.
func WriteLicensesTempFile() (string, error) {
	f, err := os.CreateTemp("", "godash-licenses-*.tpl")
	if err != nil {
		return "", err
	}
	if _, err := f.Write(licensesTpl); err != nil {
		f.Close()
		os.Remove(f.Name())
		return "", err
	}
	if err := f.Close(); err != nil {
		os.Remove(f.Name())
		return "", err
	}
	return f.Name(), nil
}

// extractFSFile copies a single embedded file to dst, optionally
// substituting appTitle for the {{APP_TITLE}} placeholder.
func extractFSFile(fsys fs.FS, prefix, name, dst, appTitle string) error {
	data, err := fs.ReadFile(fsys, filepath.Join(prefix, name))
	if err != nil {
		return err
	}
	if appTitle != "" && strings.Contains(string(data), AppTitlePlaceholder) {
		data = []byte(strings.ReplaceAll(string(data), AppTitlePlaceholder, appTitle))
	}
	return os.WriteFile(dst, data, 0644)
}

// DumpWebToTemp extracts the web assets to a temp dir (used by tests
// and the upgrade dry-run). Returns the temp dir path.
func DumpWebToTemp() (string, error) {
	dir, err := os.MkdirTemp("", "godash-web-*")
	if err != nil {
		return "", err
	}
	if err := ExtractWeb(dir, "godash test"); err != nil {
		os.RemoveAll(dir)
		return "", err
	}
	return dir, nil
}

// ensureUnusedImport keeps `fmt`/`io` available for future expansion without
// breaking the embed build. Safe to remove once used.
var _ = fmt.Sprintf
var _ = io.Discard
