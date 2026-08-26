package main

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: gen_go_build_version <output_path>")
		os.Exit(1)
	}

	if err := os.MkdirAll(filepath.Dir(os.Args[1]), 0755); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}

	out, err := os.Create(os.Args[1])
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
	defer out.Close()

	fmt.Fprintf(out, "class GoBuildVersion {\n")
	fmt.Fprintf(out, "  static const String version = '%d';\n", time.Now().Unix())
	fmt.Fprintf(out, "}\n")

	cmd := exec.Command("git", "describe", "--tags")
	b := bytes.Buffer{}
	cmd.Stdout = &b
	v := "latest"
	if err := cmd.Run(); err == nil {
		v = strings.TrimSpace(b.String())
	}
	fmt.Fprintf(out, "class AppVersion {\n")
	fmt.Fprintf(out, "  static const String version = '%s';\n", v)
	fmt.Fprintf(out, "}\n")
}
