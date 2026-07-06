//go:build tinygo

package fetch

import (
	"context"
	"fmt"

	fetch "marwan.io/wasm-fetch"
)

func Fetch(ctx context.Context, url string) ([]byte, error) {
	resp, err := fetch.Fetch(url, &fetch.Opts{
		Method: fetch.MethodGet,
		Signal: ctx,
	})
	if err != nil {
		return nil, err
	}
	if resp.Status != 200 && resp.Status != 204 {
		return nil, fmt.Errorf("fetch failed: %d", resp.Status)
	}
	return resp.Body, nil
}
