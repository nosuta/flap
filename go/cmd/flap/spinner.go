package main

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"time"
)

var spinnerFrames = []string{"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"}

// task runs a command, showing a spinner and buffering output.
// On success: clears the line and prints "✓ label".
// On failure: prints the buffered output and returns the error.
func task(label, dir, name string, args ...string) error {
	var buf bytes.Buffer
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	cmd.Stdout = &buf
	cmd.Stderr = &buf

	if err := cmd.Start(); err != nil {
		return err
	}

	done := make(chan error, 1)
	go func() { done <- cmd.Wait() }()

	frame := 0
	for {
		select {
		case err := <-done:
			clearLine()
			if err != nil {
				// print buffered output then error indicator
				fmt.Fprint(os.Stderr, buf.String())
				fmt.Fprintf(os.Stderr, "✗ %s\n", label)
				return err
			}
			fmt.Printf("✓ %s\n", label)
			return nil
		case <-time.After(80 * time.Millisecond):
			clearLine()
			fmt.Printf("  %s %s", spinnerFrames[frame%len(spinnerFrames)], label)
			frame++
		}
	}
}

func clearLine() {
	fmt.Print("\r\033[K")
}

// taskFn runs an arbitrary function with a spinner (no subprocess).
func taskFn(label string, fn func() error) error {
	done := make(chan error, 1)
	go func() { done <- fn() }()

	frame := 0
	for {
		select {
		case err := <-done:
			clearLine()
			if err != nil {
				fmt.Fprintf(os.Stderr, "✗ %s: %v\n", label, err)
				return err
			}
			fmt.Printf("✓ %s\n", label)
			return nil
		case <-time.After(80 * time.Millisecond):
			clearLine()
			// truncate long labels to fit terminal
			l := label
			if len(l) > 60 {
				l = l[:57] + "..."
			}
			fmt.Printf("  %s %s", spinnerFrames[frame%len(spinnerFrames)], strings.TrimSpace(l))
			frame++
		}
	}
}
