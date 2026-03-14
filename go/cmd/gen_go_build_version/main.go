package main

import (
	"fmt"
	"os"
	"time"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: gen_go_build_version <output_path>")
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
}
