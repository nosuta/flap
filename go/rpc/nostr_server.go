package rpc

import (
	"context"
	"flap/nostr"
	"flap/pb"
	"flap/pusher"
	"log/slog"
)

type NostrServer struct{}

func (s *NostrServer) FetchProfile(ctx context.Context, req *pb.ProfileRequest) (*pb.Profile, error) {
	slog.Info("NostrServer.FetchProfile called", "pubkey", req.Pubkey)
	return nostr.Nostr().GetProfiles(ctx, req.Pubkey)
}

func (s *NostrServer) FetchNotes(ctx context.Context, req *pb.NotesRequest, ch chan<- *pb.Response) error {
	slog.Info("NostrServer.FetchNotes called", "topic", req.Topic)

	var since *int64 = nil
	var until *int64 = nil
	if r, ok := req.Ranges.(*pb.NotesRequest_Range); ok {
		since = &r.Range.Since
		until = &r.Range.Until
	}

	// Use the global RPC pusher (set during Init), or a no-op if not set.
	push := pusher.Pusher(RPC().Push)

	notes, err := nostr.Nostr().FetchNotes(ctx, req.Topic, since, until, push)
	if err != nil {
		return err
	}

	// Stream notes from oldest to newest (reverse order of slice)
	c := len(notes.Notes)
	for i := c - 1; 0 <= i; i-- {
		select {
		case <-ctx.Done():
			return ctx.Err()
		default:
		}
		ch <- &pb.Response{
			Responses: &pb.Response_RpcResponse{
				RpcResponse: &pb.RpcResponse{
					Payload: marshalHelper(notes.Notes[i]),
				},
			},
		}
	}
	return nil
}
