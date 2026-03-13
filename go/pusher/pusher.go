package pusher

import (
	"flap/pb"
)

type Pusher func(*pb.Push) error
