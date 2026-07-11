package main

import (
	"fmt"
	"os/exec"
)

const (
	colorReset  = "\033[0m"
	colorGreen  = "\033[32m"
	colorRed    = "\033[31m"
	colorYellow = "\033[33m"
)

func checkDeps() bool {
	allOk := true
	for _, t := range requiredTools {
		if !t.detect() {
			fmt.Printf("  %s✗%s %-10s not found — install: %s%s%s\n",
				colorRed, colorReset, t.name, colorYellow, t.hint, colorReset)
			allOk = false
		} else {
			fmt.Printf("  %s✓%s %s\n", colorGreen, colorReset, t.name)
		}
	}
	// Chrome is checked separately due to OS-specific paths
	if !checkChrome() {
		fmt.Printf("  %s✗%s %-10s not found — install: %shttps://www.google.com/chrome/%s\n",
			colorRed, colorReset, "chrome", colorYellow, colorReset)
		allOk = false
	} else {
		fmt.Printf("  %s✓%s %s\n", colorGreen, colorReset, "chrome")
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
