package pb

import "context"

// MarshalHelper panics if marshaling fails. It is used by generated godash code.
func MarshalHelper(msg interface{ MarshalVT() ([]byte, error) }) []byte {
	b, err := msg.MarshalVT()
	if err != nil {
		panic(err)
	}
	return b
}

// ReverseCallFn is called by generated ReverseService functions to send a Push
// to Dart and wait for a ReverseResponse. Set this at startup via SetReverseCallFn.
var ReverseCallFn func(ctx context.Context, push *Push) ([]byte, error)

// SetReverseCallFn wires the ReverseService caller. Called once during init.
func SetReverseCallFn(fn func(ctx context.Context, push *Push) ([]byte, error)) {
	ReverseCallFn = fn
}

// PushFn is called by generated Push functions to send a fire-and-forget Push to Dart.
var PushFn func(*Push) error

// SetPushFn wires the Push sender. Called once during init.
func SetPushFn(fn func(*Push) error) {
	PushFn = fn
}
