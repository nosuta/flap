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
}

var (
	reBundleID = regexp.MustCompile(`^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*){2,}$`)
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

	return config{
		dir:      dir,
		appName:  appName,
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

// toSlug converts "My App" → "myapp"
func toSlug(s string) string {
	s = strings.ToLower(s)
	s = regexp.MustCompile(`[^a-z0-9]+`).ReplaceAllString(s, "")
	return s
}
