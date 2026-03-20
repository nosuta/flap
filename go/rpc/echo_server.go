package rpc

import (
	"context"
	"flap/pb"
	"fmt"
	"log/slog"
)

type EchoServer struct{}

func (s *EchoServer) Echo(ctx context.Context, req *pb.EchoRequest) (*pb.EchoResponse, error) {
	slog.Info("EchoServer.Echo called", "msg", req.Message)
	return &pb.EchoResponse{Message: req.Message}, nil
}

func (s *EchoServer) ServerStream(ctx context.Context, req *pb.EchoRequest, ch chan<- *pb.Response) error {
	slog.Info("EchoServer.ServerStream called", "msg", req.Message)
	for i := 0; i < 5; i++ {
		msg := fmt.Sprintf("Stream %d: %s", i, req.Message)
		slog.Debug("EchoServer.ServerStream: sending", "msg", msg)
		ch <- &pb.Response{
			Responses: &pb.Response_RpcResponse{
				RpcResponse: &pb.RpcResponse{
					Payload: marshalHelper(&pb.EchoResponse{Message: msg}),
				},
			},
		}
	}
	slog.Info("EchoServer.ServerStream finished")
	return nil
}

// marshalHelper is duplicated here for simplicity or should be in a shared place.
// Since HandleEchoService is in package pb, and it has marshalHelper, maybe we can use it?
// Actually, let's just make it available.
func marshalHelper(msg interface{ MarshalVT() ([]byte, error) }) []byte {
	b, err := msg.MarshalVT()
	if err != nil {
		panic(err)
	}
	return b
}
