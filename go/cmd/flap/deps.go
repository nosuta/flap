package main

import (
	"fmt"
	"os/exec"
)

func checkDeps() bool {
	allOk := true
	for _, t := range requiredTools {
		args := append([]string{t.name}, t.check...)
		cmd := exec.Command(args[0], args[1:]...)
		if err := cmd.Run(); err != nil {
			fmt.Printf("  ✗ %-10s not found — install: %s\n", t.name, t.hint)
			allOk = false
		} else {
			fmt.Printf("  ✓ %s\n", t.name)
		}
	}
	return allOk
}
