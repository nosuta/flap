package main

import (
	"fmt"
	"os/exec"
)

// requiredTools is the list of external tools checked by `godash doctor`.
var requiredTools = []tool{
	{name: "go", check: []string{"version"}, hint: "https://go.dev/dl/"},
	{name: "flutter", check: []string{"--version"}, hint: "https://docs.flutter.dev/get-started/install"},
	{name: "dart", check: []string{"--version"}, hint: "included with Flutter"},
	{name: "git", check: []string{"--version"}, hint: "https://git-scm.com/"},
	{name: "protoc", check: []string{"--version"}, hint: "https://grpc.io/docs/protoc-installation/"},
	{name: "npm", check: []string{"--version"}, hint: "https://nodejs.org/"},
	{name: "perl", check: []string{"--version"}, hint: "https://www.perl.org/get.html"},
	{name: "tinygo", check: []string{"version"}, hint: "https://tinygo.org/getting-started/install/"},
}

type tool struct {
	name  string
	check []string
	hint  string
}

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

// runDoctorCmd is the subcommand handler for `godash doctor`.
func runDoctorCmd() {
	fmt.Println("Checking dependencies...")
	if !checkDeps() {
		fmt.Println()
		fmt.Printf("%s✗%s Some dependencies are missing\n", colorRed, colorReset)
		return
	}
	fmt.Println()
	fmt.Printf("%s✓%s All dependencies found\n", colorGreen, colorReset)
}
