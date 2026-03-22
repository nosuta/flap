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
	// reversePending holds pending Go->Dart->Go ReverseService calls keyed by reverse_port.
	reversePending map[int64]chan []byte
	reverseMu      sync.Mutex
	reverseID      int64
}

func RPC() *rpc {
	if instance != nil {
		return instance
	}
	instance = &rpc{
		cancels:        make(map[int64]context.CancelFunc, 0),
		reversePending: make(map[int64]chan []byte),
	}
	pb.SetReverseCallFn(instance.ReverseCall)
	pb.SetPushFn(instance.Push)
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
		case *pb.Request_ReverseResponse:
			slog.Info("request: reverse_response", "port", v.ReverseResponse.ReversePort)
			r.receiveReverseResponse(v.ReverseResponse.ReversePort, v.ReverseResponse.Payload)
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

// ReverseCall sends a Push to Dart with a reverse_port set, then blocks until
// Dart replies via a ReverseResponse request or ctx is cancelled.
// Used by generated ReverseService client code.
func (r *rpc) ReverseCall(ctx context.Context, push *pb.Push) ([]byte, error) {
	r.reverseMu.Lock()
	r.reverseID++
	reversePort := r.reverseID
	ch := make(chan []byte, 1)
	r.reversePending[reversePort] = ch
	r.reverseMu.Unlock()

	push.ReversePort = reversePort
	if err := r.Push(push); err != nil {
		r.reverseMu.Lock()
		delete(r.reversePending, reversePort)
		r.reverseMu.Unlock()
		return nil, fmt.Errorf("ReverseCall: push failed: %w", err)
	}

	select {
	case <-ctx.Done():
		r.reverseMu.Lock()
		delete(r.reversePending, reversePort)
		r.reverseMu.Unlock()
		return nil, ctx.Err()
	case payload := <-ch:
		return payload, nil
	}
}

// receiveReverseResponse is called when Dart sends a ReverseResponse back to Go.
func (r *rpc) receiveReverseResponse(port int64, payload []byte) {
	r.reverseMu.Lock()
	ch, ok := r.reversePending[port]
	if ok {
		delete(r.reversePending, port)
	}
	r.reverseMu.Unlock()

	if !ok {
		slog.Warn("receiveReverseResponse: unknown port", "port", port)
		return
	}
	ch <- payload
}
