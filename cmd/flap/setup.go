package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// templateSource returns the effective template source.
// It prefers the FLAP_TEMPLATE environment variable, falling back to defaultTemplateRepo.
func templateSource() string {
	if s := os.Getenv("FLAP_TEMPLATE"); s != "" {
		return s
	}
	return defaultTemplateRepo
}

// isLocalPath reports whether src looks like a local filesystem path.
func isLocalPath(src string) bool {
	// A local path has no "://" scheme and either exists or looks like a path.
	return !strings.Contains(src, "://") && (filepath.IsAbs(src) || strings.Contains(src, string(filepath.Separator)) || src == "." || src == "..")
}

// checkRemoteTag verifies that the given tag exists on the remote template repo.
func checkRemoteTag(tag string) error {
	src := templateSource()
	if isLocalPath(src) {
		return nil
	}
	out, err := exec.Command("git", "ls-remote", "--tags", src, "refs/tags/"+tag).Output()
	if err != nil {
		return fmt.Errorf("failed to reach remote: %w", err)
	}
	if !strings.Contains(string(out), "refs/tags/"+tag) {
		return fmt.Errorf("version %q not found in %s", tag, src)
	}
	return nil
}

func cloneTemplate(cfg config) error {
	if _, err := os.Stat(cfg.dir); err == nil {
		return fmt.Errorf("directory %q already exists", cfg.dir)
	}
	src := templateSource()
	if isLocalPath(src) {
		return copyLocalTemplate(src, cfg.dir)
	}
	args := []string{"clone", "--depth=1"}
	if Version != "latest" {
		args = append(args, "--branch", Version)
	}
	args = append(args, src, cfg.dir)
	if err := task("Clone template", ".", "git", args...); err != nil {
		return err
	}
	// rename origin → upstream so users can add their own origin later
	return task("Set upstream remote", cfg.dir, "git", "remote", "rename", "origin", "upstream")
}

// copyLocalTemplate copies a local template directory to the target project directory.
func copyLocalTemplate(src, dst string) error {
	return taskFn("Copy local template", func() error {
		info, err := os.Stat(src)
		if err != nil {
			return fmt.Errorf("template path %q does not exist: %w", src, err)
		}
		if !info.IsDir() {
			return fmt.Errorf("template path %q is not a directory", src)
		}
		return copyDir(src, dst)
	})
}

// copyDir recursively copies src to dst.
func copyDir(src, dst string) error {
	return filepath.Walk(src, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		rel, err := filepath.Rel(src, path)
		if err != nil {
			return err
		}
		if rel == "." {
			return os.MkdirAll(dst, info.Mode())
		}
		target := filepath.Join(dst, rel)
		if info.IsDir() {
			return os.MkdirAll(target, info.Mode())
		}
		data, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		return os.WriteFile(target, data, info.Mode())
	})
}

func applyConfig(cfg config) error {
	return taskFn("Apply project configuration", func() error {
		// pubspec.yaml: description (display name only; name is kept as "flap" to avoid breaking internal imports)
		if err := replaceInFile(
			filepath.Join(cfg.dir, "pubspec.yaml"),
			`description: "flap"`, `description: "`+cfg.appName+`"`,
		); err != nil {
			return err
		}

		// Android: namespace + applicationId in build.gradle.kts
		_ = replaceInFile(
			filepath.Join(cfg.dir, "android", "app", "build.gradle.kts"),
			`namespace = "com.example.flap"`, `namespace = "`+cfg.bundleID+`"`,
		)
		_ = replaceInFile(
			filepath.Join(cfg.dir, "android", "app", "build.gradle.kts"),
			`applicationId = "com.example.flap"`, `applicationId = "`+cfg.bundleID+`"`,
		)

		// Android: app label in AndroidManifest.xml
		_ = replaceInFile(
			filepath.Join(cfg.dir, "android", "app", "src", "main", "AndroidManifest.xml"),
			`android:label="flap"`, `android:label="`+cfg.appName+`"`,
		)

		// iOS: bundle identifier in project.pbxproj
		_ = replaceInFile(
			filepath.Join(cfg.dir, "ios", "Runner.xcodeproj", "project.pbxproj"),
			`PRODUCT_BUNDLE_IDENTIFIER = com.example.flap;`, `PRODUCT_BUNDLE_IDENTIFIER = `+cfg.bundleID+`;`,
		)

		// iOS: app display name in Info.plist
		_ = replaceInFile(
			filepath.Join(cfg.dir, "ios", "Runner", "Info.plist"),
			`<string>Flap</string>`, `<string>`+cfg.appName+`</string>`,
		)

		// macOS: bundle identifier and product name in AppInfo.xcconfig
		_ = replaceInFile(
			filepath.Join(cfg.dir, "macos", "Runner", "Configs", "AppInfo.xcconfig"),
			`PRODUCT_NAME = flap`, `PRODUCT_NAME = `+cfg.appName,
		)
		_ = replaceInFile(
			filepath.Join(cfg.dir, "macos", "Runner", "Configs", "AppInfo.xcconfig"),
			`PRODUCT_BUNDLE_IDENTIFIER = com.example.flap`, `PRODUCT_BUNDLE_IDENTIFIER = `+cfg.bundleID,
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
