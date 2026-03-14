package main

import (
	"fmt"
	"os"
)

const templateRepo = "https://github.com/nosuta/flap"

var requiredTools = []tool{
	{name: "go", check: []string{"version"}, hint: "https://go.dev/dl/"},
	{name: "flutter", check: []string{"--version"}, hint: "https://docs.flutter.dev/get-started/install"},
	{name: "dart", check: []string{"--version"}, hint: "included with Flutter"},
	{name: "git", check: []string{"--version"}, hint: "https://git-scm.com/"},
	{name: "protoc", check: []string{"--version"}, hint: "https://grpc.io/docs/protoc-installation/"},
	{name: "npm", check: []string{"--version"}, hint: "https://nodejs.org/"},
}

type tool struct {
	name  string
	check []string
	hint  string
}

func main() {
	fmt.Println("🚀 flap - Go x Flutter project generator")
	fmt.Println()

	// 1. dependency check
	fmt.Println("Checking dependencies...")
	if !checkDeps() {
		os.Exit(1)
	}
	fmt.Println("✓ All dependencies found")
	fmt.Println()

	// 2. interactive prompts
	cfg := promptConfig()
	fmt.Println()

	// 3. clone template
	if err := cloneTemplate(cfg); err != nil {
		fatalf("Failed to clone template: %v", err)
	}

	// 4. apply config (app name, bundle id, package name)
	if err := applyConfig(cfg); err != nil {
		fatalf("Failed to apply config: %v", err)
	}

	// 5. make prepare
	fmt.Println("Running setup (this may take a few minutes)...")
	if err := runMake(cfg.dir, "prepare"); err != nil {
		fatalf("Setup failed: %v", err)
	}

	// 6. make prepare_go_wasm_test
	fmt.Println("Setting up Go wasm test environment...")
	if err := runMake(cfg.dir, "prepare_go_wasm_test"); err != nil {
		fatalf("Wasm test setup failed: %v", err)
	}

	fmt.Println()
	fmt.Printf("✓ Project created at ./%s\n", cfg.dir)
	fmt.Println()
	fmt.Printf("  cd %s\n", cfg.dir)
	fmt.Println("  make web_run       # run in browser")
	fmt.Println("  make macos_run     # run on macOS")
	fmt.Println("  make apk           # build Android APK")
}
