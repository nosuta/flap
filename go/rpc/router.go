package rpc

import (
	"context"
	"flap/pb"
)

var (
	echoServer  = &EchoServer{}
	nostrServer = &NostrServer{}
)

func HandleRPCUnified(ctx context.Context, req *pb.RpcRequest, ch chan<- *pb.Response) {
	if pb.HandleEchoService(ctx, req, ch, echoServer) {
		return
	}
	if pb.HandleNostrService(ctx, req, ch, nostrServer) {
		return
	}

	ch <- &pb.Response{
		Responses: &pb.Response_Error{
			Error: &pb.Error{
				Code:    404,
				Message: "RPC path not found",
			},
		},
	}
}
