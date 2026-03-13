package nipe4

import (
	"context"
	"errors"
	"math/bits"
	"runtime"

	"fiatjaf.com/nostr"
)

var (
	ErrDifficultyTooLow = errors.New("nipe4: insufficient difficulty")
	ErrGenerateTimeout  = errors.New("nipe4: generating proof of work took too long")
)

// Difficulty counts the number of trailing zero bits in a public key.
func Difficulty(pubkey nostr.PubKey) int {
	return difficultyBytes(pubkey)
}

func difficultyBytes(pubkey [32]byte) int {
	var zeroBits int
	for i := len(pubkey) - 1; i >= 0; i-- {
		if pubkey[i] == 0 {
			zeroBits += 8
			continue
		}
		zeroBits += bits.TrailingZeros8(pubkey[i])
		break
	}
	return zeroBits
}

// Check reports whether the public key demonstrates a sufficient proof of work difficulty.
func Check(pubkey nostr.PubKey, minDifficulty int) error {
	if Difficulty(pubkey) < minDifficulty {
		return ErrDifficultyTooLow
	}
	return nil
}

// DoWork performs work in multiple threads (given by runtime.NumCPU()) and returns the first
// public key that yields the required work.
// Returns an error if the context expires before that.
func DoWork(ctx context.Context, targetDifficulty int) (nostr.PubKey, error) {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()
	nthreads := runtime.NumCPU()
	found := make(chan nostr.PubKey)

	for range nthreads {
		go func() {
			for {
				// try 10000 times (~30ms)
				for range 10000 {
					sk := nostr.Generate()
					pk := sk.Public()

					if difficultyBytes(pk) >= targetDifficulty {
						// must select{} here otherwise a goroutine that finds a good nonce
						// right after the first will get stuck in the ch forever
						select {
						case found <- pk:
						case <-ctx.Done():
						}
						cancel()
						return
					}
				}

				// then check if the context was canceled
				select {
				case <-ctx.Done():
					return
				default:
					// otherwise keep trying
				}
			}
		}()
	}

	select {
	case <-ctx.Done():
		return nostr.ZeroPK, ErrGenerateTimeout
	case pk := <-found:
		return pk, nil
	}
}
