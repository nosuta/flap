//go:build !js

package dart_api

/*
#include <stdint.h>
#include <stdlib.h>
#include "dart_api_dl.h"
#include "bridge.h"
typedef struct bytesContainer
{
    void *message;
    int size;
} BytesContainer;
*/
import "C"
import (
	"fmt"
	"unsafe"
)

func InitializeDartAPI(api unsafe.Pointer) C.int64_t {
	return C.int64_t(C.Dart_InitializeApiDL(api))
}

func SendPointerAddress(port, ptrAddr int64) error {
	if ok := C.GoDart_PostPointerAddress(C.Dart_Port_DL(port), C.int64_t(ptrAddr)); !ok {
		return fmt.Errorf("failed to send a pointer address to Dart_Port(%d): %d", port, ptrAddr)
	}
	return nil
}

func PointerAddr(bc unsafe.Pointer) C.int64_t {
	return C.PointerAddr(bc)
}

func BytesToPointerAddress(b []byte) int64 {
	// free bc in Dart
	bc := (*C.BytesContainer)(C.malloc(C.size_t(C.sizeof_BytesContainer)))
	bc.message = C.CBytes(b)
	bc.size = C.int(len(b))
	address := PointerAddr(unsafe.Pointer(bc))
	return int64(address)
}

// Don't close the port in Go when the port is created in Dart.
func ClosePort(port int64) error {
	if ok := C.GoDart_CloseNativePort(C.Dart_Port_DL(port)); !ok {
		return fmt.Errorf("failed to close a Dart_Port(%d)", port)
	}
	return nil
}
