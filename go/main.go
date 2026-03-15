// Code as template. DO NOT EDIT.

//go:build !js

package main

/*
#include <stdint.h>
#include <stdlib.h>

typedef struct bytesContainer
{
    void *message;
    int size;
} BytesContainer;
*/
import "C"
import (
	"context"
	"fmt"
	"log/slog"
	"time"
	"unsafe"

	"flap/dart_api"
	"flap/pb"
	"flap/rpc"
)

// main as exported functions
func main() {}

//export InitializeDartAPI
func InitializeDartAPI(api unsafe.Pointer) C.int64_t {
	slog.SetLogLoggerLevel(slogLevel)

	rpc.RPC().SetPusher(pusher)
	return C.int64_t(dart_api.InitializeDartAPI(api))
}

func pusher(push *pb.Push, port int64) error {
	if port == 0 {
		return fmt.Errorf("push port is not initialized")
	}
	resp := &pb.Response{
		Responses: &pb.Response_Push{
			Push: push,
		},
	}
	b, err := resp.MarshalVT()
	if err != nil {
		return err
	}
	addr := dart_api.BytesToPointerAddress(b)
	if err := dart_api.SendPointerAddress(port, addr); err != nil {
		slog.Warn("dart_api.SendPointerAddress failed", "error", err.Error())
	}
	return nil
}

//export RPC
func RPC(port C.int64_t, payload *C.BytesContainer) {
	b := C.GoBytes(payload.message, payload.size)
	C.free(unsafe.Pointer(payload.message))
	C.free(unsafe.Pointer(payload))

	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), time.Millisecond*10000)
		defer cancel()
		req := &pb.Request{}
		if err := req.UnmarshalVT(b); err != nil {
			resp := &pb.Response{
				Responses: &pb.Response_Error{
					Error: &pb.Error{
						Message: err.Error(),
					},
				},
			}
			e, err := resp.MarshalVT()
			if err != nil {
				slog.Error("MUST FIX, failed to marshal error response", "error", err.Error())
			}
			addr := dart_api.BytesToPointerAddress(e)
			if err := dart_api.SendPointerAddress(int64(port), addr); err != nil {
				slog.Warn("dart_api.SendPointerAddress failed", "error", err.Error())
			}
			return
		}

		for ret := range rpc.RPC().Call(ctx, req) {
			addr := dart_api.BytesToPointerAddress(ret)
			if err := dart_api.SendPointerAddress(int64(port), addr); err != nil {
				slog.Warn("dart_api.SendPointerAddress failed", "error", err.Error())
				break
			}
		}
		resp := &pb.Response{
			Responses: &pb.Response_Done{
				Done: &pb.Done{},
			},
		}
		done, err := resp.MarshalVT()
		if err != nil {
			slog.Error("MUST FIX, failed to marshal done response", "err", err.Error())
			return
		}
		addr := dart_api.BytesToPointerAddress(done)
		if err := dart_api.SendPointerAddress(int64(port), addr); err != nil {
			slog.Warn("dart_api.SendPointerAddress failed", "error", err.Error())
		}

		// ! Following code crashes the app when the port is created in Dart.
		// So we must close the port in Dart in this case.
		// dart_api.ClosePort(int64(port))

	}()
}
