// Package bench provides the shared EchoService-style handlers used by the
// latency benchmark harness (benchmark/).
//
// The echo semantics mirror the template EchoServer.Echo at the envelope
// level: the RpcRequest payload is returned unchanged as an RpcResponse.
package bench

import (
	"context"
	"log/slog"

	"github.com/nosuta/godash/pb"
	"github.com/nosuta/godash/rpc"
)

// EchoPath is the unary echo RPC path handled by the benchmark.
const EchoPath = "/bench.EchoService/Echo"

// Install wires the benchmark entry point and RPC dispatch into the rpc
// package. Call it before the first request arrives (package init). It also
// silences per-request info logging so it does not distort the numbers.
func Install() {
	slog.SetLogLoggerLevel(slog.LevelError)
	rpc.SetEntryPoint(func(databasePath, appEncryptionKey string) error {
		_ = databasePath
		_ = appEncryptionKey
		return nil
	})
	rpc.SetHandleRPC(handleRPC)
}

func handleRPC(_ context.Context, req *pb.RpcRequest, ch chan<- *pb.Response) {
	if req.GetPath() != EchoPath {
		ch <- &pb.Response{
			Responses: &pb.Response_Error{
				Error: &pb.Error{Code: 404, Message: "RPC path not found"},
			},
		}
		return
	}
	ch <- &pb.Response{
		Responses: &pb.Response_RpcResponse{
			RpcResponse: &pb.RpcResponse{Payload: req.GetPayload()},
		},
	}
}
