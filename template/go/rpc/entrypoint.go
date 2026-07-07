// Code as template. DO NOT EDIT.

package rpc

func EntryPoint(databasePath, appEncryptionKey string) error {
	// Called once when the native library / web worker starts.
	// Initialize app-wide state here (open database, configure services, etc.).
	return nil
}

func Close() {
	// Clean up app-wide state here.
}
