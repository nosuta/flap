package main

import (
	"bytes"
	"fmt"
	"os/exec"
	"strings"
)

// gitRun runs `git args...` in dir, returning combined stdout/stderr.
func gitRun(dir string, args ...string) (string, error) {
	cmd := exec.Command("git", args...)
	cmd.Dir = dir
	var out bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = &out
	err := cmd.Run()
	return out.String(), err
}

// gitRunTrim returns the trimmed combined output of a git command.
func gitRunTrim(dir string, args ...string) (string, error) {
	out, err := gitRun(dir, args...)
	return strings.TrimSpace(out), err
}

// isGitRepo reports whether dir is inside a git working tree.
func isGitRepo(dir string) bool {
	_, err := gitRun(dir, "rev-parse", "--git-dir")
	return err == nil
}

// gitCommitWithUser creates a commit with the given message using a
// best-effort local user identity. If the system already has user.name and
// user.email configured, those are used; otherwise a placeholder identity
// is applied just for this commit.
func gitCommitWithUser(dir, message string) error {
	if _, err := gitRun(dir, "config", "user.name"); err != nil {
		_ = gitConfig(dir, "user.name", "Godash")
	}
	if _, err := gitRun(dir, "config", "user.email"); err != nil {
		_ = gitConfig(dir, "user.email", "godash@localhost")
	}
	_, err := gitRun(dir, "commit", "-m", message)
	return err
}

func gitConfig(dir, key, value string) error {
	_, err := gitRun(dir, "config", key, value)
	return err
}

// remoteDefaultBranch queries the remote for its HEAD branch (e.g. "main").
// Falls back to "main" if it cannot be determined.
func remoteDefaultBranch(remoteURL string) string {
	cmd := exec.Command("git", "ls-remote", "--symref", remoteURL, "HEAD")
	var out bytes.Buffer
	cmd.Stdout = &out
	if err := cmd.Run(); err != nil {
		return "main"
	}
	for _, line := range strings.Split(out.String(), "\n") {
		if !strings.HasPrefix(line, "ref:") {
			continue
		}
		fields := strings.Fields(line)
		if len(fields) >= 2 {
			ref := fields[1]
			if strings.HasPrefix(ref, "refs/heads/") {
				return strings.TrimPrefix(ref, "refs/heads/")
			}
		}
	}
	return "main"
}

// remoteURL returns the fetch URL of the named remote, or "" if unset.
func remoteURL(dir, name string) string {
	out, err := gitRunTrim(dir, "remote", "get-url", name)
	if err != nil {
		return ""
	}
	return out
}

// gitStatusDirty reports whether the working tree has uncommitted changes.
func gitStatusDirty(dir string) bool {
	out, err := gitRun(dir, "status", "--porcelain")
	if err != nil {
		return true // assume dirty on error to be safe
	}
	return strings.TrimSpace(out) != ""
}

// fatalGit is a small helper for unrecoverable git errors.
func fatalGit(label, dir string, err error) error {
	return fmt.Errorf("%s in %s: %w", label, dir, err)
}
