// Code as template. DO NOT EDIT.

package rpc

import (
	"flap/nostr"
)

func EntryPoint(databasePath, appEncryptionKey string) error {
	if err := nostr.Nostr().Init(databasePath, appEncryptionKey); err != nil {
		return err
	}
	return nil
}

func Close() {
	nostr.Nostr().Close()
}
