package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strings"
)

type config struct {
	dir      string // directory / project name
	appName  string // display name e.g. "My App"
	bundleID string // e.g. com.example.myapp
	pkgName  string // Go module name e.g. myapp
}

var (
	reBundleID = regexp.MustCompile(`^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*){2,}$`)
	rePkgName  = regexp.MustCompile(`^[a-z][a-z0-9_]*$`)

	// Go standard library package names that would cause ambiguous import errors
	goStdLibNames = map[string]bool{
		"archive": true, "bufio": true, "builtin": true, "bytes": true,
		"compress": true, "container": true, "context": true, "crypto": true,
		"database": true, "debug": true, "embed": true, "encoding": true,
		"errors": true, "expvar": true, "flag": true, "fmt": true,
		"go": true, "hash": true, "html": true, "http": true,
		"image": true, "index": true, "io": true, "log": true,
		"maps": true, "math": true, "mime": true, "net": true,
		"os": true, "path": true, "plugin": true, "reflect": true,
		"regexp": true, "runtime": true, "slices": true, "sort": true,
		"strconv": true, "strings": true, "sync": true, "syscall": true,
		"testing": true, "text": true, "time": true, "unicode": true,
		"unsafe": true,
	}
)

func promptConfig() config {
	r := bufio.NewReader(os.Stdin)

	appName := ask(r, "App name", "My App", func(s string) bool { return s != "" })
	dir := ask(r, "Directory name", toSlug(appName), func(s string) bool { return s != "" })
	bundleID := ask(r, "Bundle ID (e.g. com.example.myapp)", "com.example."+toSlug(appName), func(s string) bool {
		if !reBundleID.MatchString(s) {
			fmt.Println("  Must be lowercase reverse-domain format, e.g. com.example.myapp")
			return false
		}
		return true
	})
	pkgName := ask(r, "Go package name", toSlug(appName), func(s string) bool {
		if !rePkgName.MatchString(s) {
			fmt.Println("  Must be lowercase letters, digits, underscores only")
			return false
		}
		if goStdLibNames[s] {
			fmt.Printf("  %q conflicts with a Go standard library package name, choose another\n", s)
			return false
		}
		return true
	})

	return config{
		dir:      dir,
		appName:  appName,
		bundleID: bundleID,
		pkgName:  pkgName,
	}
}

func ask(r *bufio.Reader, label, defaultVal string, validate func(string) bool) string {
	for {
		fmt.Printf("%s [%s]: ", label, defaultVal)
		line, _ := r.ReadString('\n')
		line = strings.TrimSpace(line)
		if line == "" {
			line = defaultVal
		}
		if validate(line) {
			return line
		}
	}
}

// toSlug converts "My App" → "myapp"
func toSlug(s string) string {
	s = strings.ToLower(s)
	s = regexp.MustCompile(`[^a-z0-9]+`).ReplaceAllString(s, "")
	return s
}
