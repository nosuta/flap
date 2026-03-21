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
	{name: "perl", check: []string{"--version"}, hint: "https://www.perl.org/get.html"},
	{name: "tinygo", check: []string{"version"}, hint: "https://tinygo.org/getting-started/install/"},
}

type tool struct {
	name  string
	check []string
	hint  string
}

func main() {
	fmt.Println("flap - Go x Flutter frontend template")
	fmt.Println()

	// 1. dependency check
	fmt.Println("Checking dependencies...")
	if !checkDeps() {
		os.Exit(1)
	}
	fmt.Printf("%s✓%s All dependencies found\n", colorGreen, colorReset)
	fmt.Println()

	// 2. interactive prompts
	cfg := promptConfig()
	fmt.Println()

	// cleanup on any failure after directory is created
	cleanup := func() {
		if _, err := os.Stat(cfg.dir); err == nil {
			fmt.Fprintf(os.Stderr, "Cleaning up ./%s ...\n", cfg.dir)
			os.RemoveAll(cfg.dir)
		}
	}

	// 3. clone template
	if err := cloneTemplate(cfg); err != nil {
		fatalf("Failed to clone template: %v", err)
	}

	// 4. apply config
	if err := applyConfig(cfg); err != nil {
		cleanup()
		fatalf("Failed to apply config: %v", err)
	}

	// 5. custom.mk
	if err := setupCustomMk(cfg.dir); err != nil {
		cleanup()
		fatalf("Failed to create custom.mk: %v", err)
	}

	// 6. make prepare
	if err := runMake(cfg.dir, "Prepare environment", "prepare"); err != nil {
		cleanup()
		fatalf("Setup failed: %v", err)
	}

	// 7. make prepare_go_wasm_test
	if err := runMake(cfg.dir, "Prepare Go wasm test", "prepare_go_wasm_test"); err != nil {
		cleanup()
		fatalf("Wasm test setup failed: %v", err)
	}

	fmt.Println()
	fmt.Printf("%s✓%s Project created at ./%s\n", colorGreen, colorReset, cfg.dir)
	fmt.Println()
	fmt.Printf("  cd %s\n", cfg.dir)
	fmt.Println("  make -s web_run       # run in browser")
	fmt.Println("  make -s macos_run     # run on macOS")
	fmt.Println("  make -s apk           # build Android APK")
}

func fatalf(format string, args ...any) {
	fmt.Fprintf(os.Stderr, colorRed+"✗"+colorReset+" "+format+"\n", args...)
	os.Exit(1)
}
