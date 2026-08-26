package main

import (
	"fmt"
	"os"
)

// runClean handles `godash clean`.
func runClean() {
	env, err := loadProjectEnv("")
	if err != nil {
		fatalf("%v", err)
	}
	script := envShell(env) + "\n" + buildCleanScript(env)
	if err := runShellTask("Clean build artifacts", env.Root, script); err != nil {
		os.Exit(1)
	}
	fmt.Println()
	fmt.Printf("%s✓%s Cleaned\n", colorGreen, colorReset)
}

// runReset handles `godash reset`.
func runReset() {
	env, err := loadProjectEnv("")
	if err != nil {
		fatalf("%v", err)
	}
	script := envShell(env) + "\n" + buildResetScript(env)
	if err := runShellTask("Reset project", env.Root, script); err != nil {
		os.Exit(1)
	}
	fmt.Println()
	fmt.Printf("%s✓%s Project reset to template state\n", colorGreen, colorReset)
}
