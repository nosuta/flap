// Code as template. ADD YOUR SERVICE HANDLERS.

package rpc

import (
	"context"

	"github.com/nosuta/godash/pb"
	flap "flap/pb"
)

var (
	echoServer = &EchoServer{}
)

func HandleRPCImpl(ctx context.Context, req *pb.RpcRequest, ch chan<- *pb.Response) {
	if flap.HandleEchoRPC(ctx, req, ch, echoServer) {
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
