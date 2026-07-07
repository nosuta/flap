// Code as template. DO NOT EDIT.

//go:build js && tinygo

package main

import (
	"flap/rpc"
	"log/slog"
)

// main as a web worker
func main() {
	slog.SetLogLoggerLevel(slog.LevelInfo)
	defer func() {
		rpc.Close()
		if r := recover(); r != nil {
			slog.Error("main recovered from panic", "message", r)
		}
	}()

	webWorker()
	select {}
}
