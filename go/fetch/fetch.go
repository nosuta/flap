//go:build !tinygo

package fetch

import (
	"context"
	"fmt"
	"io"
	"net/http"
)

func Fetch(ctx context.Context, url string) ([]byte, error) {
	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return nil, err
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != 200 && resp.StatusCode != 204 {
		return nil, fmt.Errorf("fetch failed: %d", resp.StatusCode)
	}
	return io.ReadAll(resp.Body)
}
