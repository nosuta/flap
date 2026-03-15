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
	pkgName  string // dart package name e.g. "my_app"
	bundleID string // e.g. com.example.myapp
}

var (
	// Dart package name: lowercase letters, digits, underscores; must start with letter or underscore
	rePkgName  = regexp.MustCompile(`^[a-z_][a-z0-9_]*$`)
	reBundleID = regexp.MustCompile(`^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*){2,}$`)
)

func promptConfig() config {
	r := bufio.NewReader(os.Stdin)

	appName := ask(r, "App name", "My App", func(s string) bool { return s != "" })
	defaultPkg := toPackageName(appName)
	pkgName := ask(r, "Package name (pubspec.yaml name)", defaultPkg, func(s string) bool {
		if !rePkgName.MatchString(s) {
			fmt.Println("  Must be lowercase letters, digits, underscores only (e.g. my_app)")
			return false
		}
		return true
	})
	dir := ask(r, "Directory name", pkgName, func(s string) bool { return s != "" })
	bundleID := ask(r, "Bundle ID (e.g. com.example.myapp)", "com.example."+strings.ReplaceAll(pkgName, "_", ""), func(s string) bool {
		if !reBundleID.MatchString(s) {
			fmt.Println("  Must be lowercase reverse-domain format, e.g. com.example.myapp")
			return false
		}
		return true
	})

	return config{
		dir:      dir,
		appName:  appName,
		pkgName:  pkgName,
		bundleID: bundleID,
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

// toPackageName converts "My App" → "my_app" (valid Dart package name)
func toPackageName(s string) string {
	s = strings.ToLower(s)
	s = regexp.MustCompile(`[^a-z0-9]+`).ReplaceAllString(s, "_")
	s = strings.Trim(s, "_")
	if s == "" {
		s = "my_app"
	}
	return s
}
