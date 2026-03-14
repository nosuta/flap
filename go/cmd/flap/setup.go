package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func cloneTemplate(cfg config) error {
	if _, err := os.Stat(cfg.dir); err == nil {
		return fmt.Errorf("directory %q already exists", cfg.dir)
	}
	fmt.Printf("Cloning template into ./%s ...\n", cfg.dir)
	return run(".", "git", "clone", "--depth=1", templateRepo, cfg.dir)
}

func applyConfig(cfg config) error {
	fmt.Println("Applying project configuration...")

	// pubspec.yaml: name + description
	if err := replaceInFile(
		filepath.Join(cfg.dir, "pubspec.yaml"),
		"name: flap", "name: "+cfg.pkgName,
	); err != nil {
		return err
	}
	if err := replaceInFile(
		filepath.Join(cfg.dir, "pubspec.yaml"),
		`description: "flap"`, `description: "`+cfg.appName+`"`,
	); err != nil {
		return err
	}

	// go.mod: module name
	if err := replaceInFile(
		filepath.Join(cfg.dir, "go", "go.mod"),
		"module flap", "module "+cfg.pkgName,
	); err != nil {
		return err
	}

	// core.env: LIB_NAME
	if err := replaceInFile(
		filepath.Join(cfg.dir, "core.env"),
		"LIB_NAME=libflap", "LIB_NAME=lib"+cfg.pkgName,
	); err != nil {
		return err
	}

	// Android bundle ID
	if err := replaceInFile(
		filepath.Join(cfg.dir, "android", "app", "build.gradle.kts"),
		`applicationId = "com.example.flap"`, `applicationId = "`+cfg.bundleID+`"`,
	); err != nil {
		// not fatal — android dir may not exist yet (created by make prepare)
		fmt.Printf("  note: android bundle ID will be set during prepare\n")
	}

	return nil
}

func runMake(dir, target string) error {
	return run(dir, "make", target)
}

func run(dir, name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func replaceInFile(path, old, new string) error {
	b, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	updated := strings.ReplaceAll(string(b), old, new)
	return os.WriteFile(path, []byte(updated), 0644)
}

func fatalf(format string, args ...any) {
	fmt.Fprintf(os.Stderr, "✗ "+format+"\n", args...)
	os.Exit(1)
}
