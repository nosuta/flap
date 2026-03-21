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
	// dartReplies holds pending Go->Dart->Go calls keyed by reply_port.
	dartReplies map[int64]chan []byte
	dartReplyMu sync.Mutex
	dartReplyID int64
}

func RPC() *rpc {
	if instance != nil {
		return instance
	}
	instance = &rpc{
		cancels:     make(map[int64]context.CancelFunc, 0),
		dartReplies: make(map[int64]chan []byte),
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
		case *pb.Request_DartReply:
			slog.Info("request: dart_reply", "port", v.DartReply.ReplyPort)
			r.ReceiveDartReply(v.DartReply.ReplyPort, v.DartReply.Payload)
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

// CallDart sends a Push to Dart with a reply_port set, then blocks until Dart
// calls back via ReceiveDartReply or ctx is cancelled.
// The returned bytes are the raw payload sent back by Dart.
func (r *rpc) CallDart(ctx context.Context, push *pb.Push) ([]byte, error) {
	r.dartReplyMu.Lock()
	r.dartReplyID++
	replyPort := r.dartReplyID
	ch := make(chan []byte, 1)
	r.dartReplies[replyPort] = ch
	r.dartReplyMu.Unlock()

	push.ReplyPort = replyPort
	if err := r.Push(push); err != nil {
		r.dartReplyMu.Lock()
		delete(r.dartReplies, replyPort)
		r.dartReplyMu.Unlock()
		return nil, fmt.Errorf("CallDart: push failed: %w", err)
	}

	select {
	case <-ctx.Done():
		r.dartReplyMu.Lock()
		delete(r.dartReplies, replyPort)
		r.dartReplyMu.Unlock()
		return nil, ctx.Err()
	case payload := <-ch:
		return payload, nil
	}
}

// ReceiveDartReply is called by the bridge when Dart sends a reply to a
// Go->Dart->Go call. port must match the reply_port that was set in the Push.
func (r *rpc) ReceiveDartReply(port int64, payload []byte) {
	r.dartReplyMu.Lock()
	ch, ok := r.dartReplies[port]
	if ok {
		delete(r.dartReplies, port)
	}
	r.dartReplyMu.Unlock()

	if !ok {
		slog.Warn("ReceiveDartReply: unknown port", "port", port)
		return
	}
	ch <- payload
}
