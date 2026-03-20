//go:build js

package rpc

import (
	"context"
	"flap/pb"
	"log/slog"
)

func HandleRPC(ctx context.Context, req *pb.RpcRequest, ch chan<- *pb.Response) {
	slog.Info("HandleRPC (TinyGo/Unified)", "path", req.Path)
	HandleRPCUnified(ctx, req, ch)
}
