//go:build !js

package rpc

import (
	"context"
	"flap/pb"
	"log/slog"
)

func HandleConnect(ctx context.Context, req *pb.ConnectRequest, ch chan<- *pb.Response) {
	slog.Info("HandleConnect (Native/Unified)", "path", req.Path)
	HandleConnectUnified(ctx, req, ch)
}
