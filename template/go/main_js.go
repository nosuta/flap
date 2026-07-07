// Code as template. DO NOT EDIT.

//go:build js

package main

import (
	"github.com/nosuta/godash/rpc"
	"github.com/nosuta/godash/web"
	nosutarpc "flap/rpc"
)

func init() {
	rpc.SetEntryPoint(nosutarpc.EntryPoint)
	rpc.SetHandleRPC(nosutarpc.HandleRPCImpl)
}

func webWorker() {
	web.RunWebWorker()
}
