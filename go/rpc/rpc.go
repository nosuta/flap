package rpc

import (
	"context"
	"fmt"
	"log/slog"
	"sync"

	"flap/pb"
	"flap/pusher"

	"golang.org/x/exp/maps"
)

var instance *rpc

type rpc struct {
	mu             sync.Mutex
	nativePushPort int64
	pusher         pusher.Pusher
	cancels        map[int64]context.CancelFunc
}

func RPC() *rpc {
	if instance != nil {
		return instance
	}
	instance = &rpc{
		cancels: make(map[int64]context.CancelFunc, 0),
	}
	return instance
}

// Pusher returns the global RPC pusher, which sends pb.Push to the bridge.
// It is safe to call after Init has set the underlying pusher via SetPusher.
func Pusher() pusher.Pusher {
	return RPC().Push
}

func (r *rpc) SetPusher(p func(*pb.Push, int64) error) {
	r.mu.Lock()
	r.pusher = func(push *pb.Push) error {
		return p(push, r.nativePushPort)
	}
	r.mu.Unlock()
}

// Push, [pusher.Pusher] compatible
func (r *rpc) Push(push *pb.Push) error {
	if r.pusher == nil {
		return fmt.Errorf("pusher is nil")
	}
	return r.pusher(push)
}

func (r *rpc) Call(ctx context.Context, req *pb.Request) chan []byte {
	ch := make(chan []byte)

	select {
	case <-ctx.Done():
		close(ch)
		return ch
	default:
	}

	go func() {
		r.mu.Lock()
		ctx, r.cancels[req.Port] = context.WithCancel(ctx)
		r.mu.Unlock()
		defer func() {
			r.mu.Lock()
			if cancel, ok := r.cancels[req.Port]; ok {
				cancel()
				delete(r.cancels, req.Port)
			}
			r.mu.Unlock()
			keys := maps.Keys(r.cancels)
			slog.Info("remained ports in cancels", "list", keys)
			close(ch)
		}()

		slog.Info("RPC handle request", "port", req.Port)

		switch v := req.Requests.(type) {
		case *pb.Request_Cancel:
			slog.Info("request: cancel")
			targetPort := req.GetCancel().Port
			r.mu.Lock()
			if cancel, ok := r.cancels[targetPort]; ok {
				cancel()
				delete(r.cancels, targetPort)
			}
			r.mu.Unlock()
		case *pb.Request_Init:
			slog.Info("request: init")
			r.nativePushPort = v.Init.GetPushPort()
			aek := v.Init.GetAppEncryptionKey()
			databasePath := "/database.db"
			supportDir := v.Init.GetSupportDir()
			if supportDir != "" {
				databasePath = supportDir + databasePath
			}
			slog.Info("databasePath", "path", databasePath)
			if err := EntryPoint(databasePath, aek); err != nil {
				sendError(ch, err, 500)
			}
		case *pb.Request_RpcRequest:
			slog.Info("request: rpc", "path", v.RpcRequest.Path)
			// HandleRPC is expected to push one or more *pb.Response chunks to the channel.
			rpcCh := make(chan *pb.Response)
			go func() {
				HandleRPC(ctx, v.RpcRequest, rpcCh)
				close(rpcCh)
			}()
			for resp := range rpcCh {
				e, err := resp.MarshalVT()
				if err != nil {
					slog.Error("failed to marshal RPC response", "error", err.Error())
					continue
				}
				slog.Info("RPCRequest: sending chunk to Dart", "len", len(e))
				ch <- e
			}
		default:
			err := fmt.Errorf("unsupported request: %T", v)
			sendError(ch, err, 500)
		}
	}()

	return ch
}

func sendError(ch chan<- []byte, err error, code int32) {
	slog.Error("sending error", "message", err)
	message := ""
	if err != nil {
		message = err.Error()
	}
	resp := &pb.Response{
		Responses: &pb.Response_Error{
			Error: &pb.Error{
				Code:    code,
				Message: message,
			},
		},
	}
	e, er := resp.MarshalVT()
	if er != nil {
		panic(err)
	}
	ch <- e
}
