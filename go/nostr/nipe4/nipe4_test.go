package nipe4

import (
	"context"
	"errors"
	"fmt"
	"testing"
	"time"

	"fiatjaf.com/nostr"
)

func TestCheck(t *testing.T) {
	pk, err := nostr.PubKeyFromHex("2d383356c40c636325aa44cdb9c87ec1d8ecc728ec045af0f502c3c77e000000")
	if err != nil {
		t.Fatal(err)
	}
	tests := []struct {
		minDifficulty int
		wantErr       error
	}{
		{-1, nil},
		{0, nil},
		{1, nil},
		{19, nil},
		{25, nil},
		{26, ErrDifficultyTooLow},
		{37, ErrDifficultyTooLow},
	}
	for i, tc := range tests {
		if err := Check(pk, tc.minDifficulty); err != tc.wantErr {
			t.Errorf("%d: Check(%q, %d) returned %v; want err: %v", i, pk, tc.minDifficulty, err, tc.wantErr)
		}
	}
}

func TestDoWorkShort(t *testing.T) {
	_, err := DoWork(context.Background(), 2)
	if err != nil {
		t.Fatal(err)
	}
}

func TestDoWorkLong(t *testing.T) {
	if testing.Short() {
		t.Skip("too consuming for short mode")
	}
	for _, difficulty := range []int{8, 16} {
		t.Run(fmt.Sprintf("%dbits", difficulty), func(t *testing.T) {
			t.Parallel()
			ctx, cancel := context.WithTimeout(context.Background(), time.Minute*3)
			defer cancel()
			pk, err := DoWork(ctx, difficulty)
			if err != nil {
				t.Fatal(err)
			}
			if err := Check(pk, difficulty); err != nil {
				t.Error(err)
			}
		})
	}
}

func TestDoWorkTimeout(t *testing.T) {
	done := make(chan error)
	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), time.Millisecond)
		defer cancel()
		_, err := DoWork(ctx, 256)
		done <- err
	}()
	select {
	case <-time.After(time.Second):
		t.Error("DoWork took too long to timeout")
	case err := <-done:
		if !errors.Is(err, ErrGenerateTimeout) {
			t.Errorf("DoWork returned %v; want ErrDoWorkTimeout", err)
		}
	}
}
