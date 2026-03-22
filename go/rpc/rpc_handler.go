// Code as template. ADD YOUR SERVICE HANDLERS.

package rpc

import (
	"context"
	"flap/pb"
)

var (
	echoServer  = &EchoServer{}
	nostrServer = &NostrServer{}
)

func HandleRPCImpl(ctx context.Context, req *pb.RpcRequest, ch chan<- *pb.Response) {
	if pb.HandleEchoRPC(ctx, req, ch, echoServer) {
		return
	}
	if pb.HandleNostrRPC(ctx, req, ch, nostrServer) {
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
