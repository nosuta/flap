//go:build !js

package rpc

import (
	"context"
	"flap/pb"
	"log/slog"
)

func HandleRPC(ctx context.Context, req *pb.RpcRequest, ch chan<- *pb.Response) {
	slog.Info("HandleRPC (Native/Unified)", "path", req.Path)
	HandleRPCImpl(ctx, req, ch)
}
