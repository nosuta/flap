package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func cloneTemplate(cfg config) error {
	if _, err := os.Stat(cfg.dir); err == nil {
		return fmt.Errorf("directory %q already exists", cfg.dir)
	}
	if err := task("Clone template", ".", "git", "clone", "--depth=1", templateRepo, cfg.dir); err != nil {
		return err
	}
	// rename origin → upstream so users can add their own origin later
	return task("Set upstream remote", cfg.dir, "git", "remote", "rename", "origin", "upstream")
}

func applyConfig(cfg config) error {
	return taskFn("Apply project configuration", func() error {
		// pubspec.yaml: name + description
		if err := replaceInFile(
			filepath.Join(cfg.dir, "pubspec.yaml"),
			`description: "flap"`, `description: "`+cfg.appName+`"`,
		); err != nil {
			return err
		}

		// Android bundle ID (not fatal — dir created later by make prepare)
		_ = replaceInFile(
			filepath.Join(cfg.dir, "android", "app", "build.gradle.kts"),
			`applicationId = "com.example.flap"`, `applicationId = "`+cfg.bundleID+`"`,
		)
		return nil
	})
}

func replaceInFile(path, old, new string) error {
	b, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	updated := strings.ReplaceAll(string(b), old, new)
	return os.WriteFile(path, []byte(updated), 0644)
}

func runMake(dir, label, target string) error {
	return task(label, dir, "make", target)
}

func setupCustomMk(dir string) error {
	return taskFn("Configure custom.mk", func() error {
		ndkPath := findNDK()
		content := "NDK_PATH=" + ndkPath + "\n"
		return os.WriteFile(filepath.Join(dir, "custom.mk"), []byte(content), 0644)
	})
}

// findNDK looks for the Android NDK in common SDK locations.
// Returns the path to the latest NDK version found, or empty string if not found.
func findNDK() string {
	home, err := os.UserHomeDir()
	if err != nil {
		return ""
	}
	candidates := []string{
		filepath.Join(home, "Library", "Android", "sdk", "ndk"),          // macOS
		filepath.Join(home, "Android", "Sdk", "ndk"),                     // Linux
		filepath.Join(home, "AppData", "Local", "Android", "Sdk", "ndk"), // Windows
	}
	for _, base := range candidates {
		entries, err := os.ReadDir(base)
		if err != nil || len(entries) == 0 {
			continue
		}
		// pick the last entry (highest version, dirs are sorted lexically)
		for i := len(entries) - 1; i >= 0; i-- {
			if entries[i].IsDir() {
				return filepath.Join(base, entries[i].Name())
			}
		}
	}
	return ""
}
