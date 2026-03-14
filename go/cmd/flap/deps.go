package main

import (
	"fmt"
	"os/exec"
)

func checkDeps() bool {
	allOk := true
	for _, t := range requiredTools {
		if !t.detect() {
			fmt.Printf("  ✗ %-10s not found — install: %s\n", t.name, t.hint)
			allOk = false
		} else {
			fmt.Printf("  ✓ %s\n", t.name)
		}
	}
	// Chrome is checked separately due to OS-specific paths
	if !checkChrome() {
		fmt.Printf("  ✗ %-10s not found — install: https://www.google.com/chrome/\n", "chrome")
		allOk = false
	} else {
		fmt.Printf("  ✓ %s\n", "chrome")
	}
	return allOk
}

func (t tool) detect() bool {
	args := append([]string{t.name}, t.check...)
	return exec.Command(args[0], args[1:]...).Run() == nil
}

// checkChrome tries known Chrome binary names across macOS, Linux, Windows.
func checkChrome() bool {
	candidates := []string{
		"google-chrome",
		"google-chrome-stable",
		"chromium",
		"chromium-browser",
		"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
	}
	for _, c := range candidates {
		if exec.Command(c, "--version").Run() == nil {
			return true
		}
	}
	return false
}
