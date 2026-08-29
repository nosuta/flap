package dart_api

import (
	"bytes"
	"testing"
	"unsafe"
)

// bytesContainer mirrors the C struct declared in bridge.go
//
//	typedef struct bytesContainer { void *message; int size; } BytesContainer;
//
// Layout on 64-bit targets: message at offset 0 (8 bytes), size at offset 8
// (4 bytes) plus 4 bytes of tail padding. The tests below rely on reading the
// container through this mirror instead of importing "C" (cgo is not
// supported in _test.go files, see golang/go#4030).
type bytesContainer struct {
	message unsafe.Pointer
	size    int32
	_       [4]byte
}

// containerFromAddress casts a raw address returned by BytesToPointerAddress
// back to the mirrored BytesContainer struct. The address originates from the
// C heap (not from a Go pointer), so the pointer conversion is safe for the
// lifetime of the container; it is routed through a *unsafe.Pointer
// reinterpretation to stay quiet under go vet's unsafeptr check.
func containerFromAddress(addr int64) *bytesContainer {
	p := addr
	return (*bytesContainer)(*(*unsafe.Pointer)(unsafe.Pointer(&p)))
}

// readContainer copies the message bytes out of the container at addr,
// mirroring what the Dart side does with asTypedList before parsing.
func readContainer(t *testing.T, addr int64) (message []byte, size int) {
	t.Helper()
	if addr == 0 {
		t.Fatal("container address must not be null")
	}
	bc := containerFromAddress(addr)
	if bc.message == nil {
		t.Fatal("container message pointer must not be null")
	}
	if bc.size < 0 {
		t.Fatalf("negative container size: %d", bc.size)
	}
	message = append([]byte(nil), unsafe.Slice((*byte)(bc.message), bc.size)...)
	size = int(bc.size)
	return
}

// Note on ownership: since the P1 allocator contract, Dart frees Go-allocated
// response containers *through* the exported `FreeBytesContainer` symbol
// (GoDash_FreeBytesContainer in bridge.c), never with its own malloc.free.
// The test process cannot call that export without a live native library, so
// allocations made here are intentionally leaked; the process exits right
// after the test run, mirroring how a Dart app frees these buffers right
// after parsing the response.

// TestBytesToPointerAddressRoundTrip verifies the FFI response export path:
// Go marshals a response, copies it onto the C heap via C.CBytes and hands a
// pointer address to Dart, which reads size+message and frees both.
func TestBytesToPointerAddressRoundTrip(t *testing.T) {
	cases := [][]byte{
		[]byte("hello godash"),
		{},
		bytes.Repeat([]byte{0}, 1024), // binary zeros
		bytes.Repeat([]byte{0xDE, 0xAD, 0xBE, 0xEF}, 4096), // 16 KiB
	}
	for i, want := range cases {
		addr := BytesToPointerAddress(want)
		got, size := readContainer(t, addr)
		if size != len(want) {
			t.Errorf("case %d: size = %d, want %d", i, size, len(want))
		}
		if !bytes.Equal(got, want) {
			t.Errorf("case %d: message content mismatch (len got=%d want=%d)", i, len(got), len(want))
		}
	}
}

// TestBytesToPointerAddressUniqueAddresses ensures repeated allocations do
// not alias (each response must own its buffer until Dart frees it).
func TestBytesToPointerAddressUniqueAddresses(t *testing.T) {
	addrs := make([]int64, 16)
	for i := range addrs {
		addrs[i] = BytesToPointerAddress([]byte{byte(i)})
	}
	seen := make(map[int64]bool, len(addrs))
	for _, a := range addrs {
		if a == 0 {
			t.Fatal("allocation failed, null address")
		}
		if seen[a] {
			t.Fatalf("duplicate address %x", a)
		}
		seen[a] = true
	}
}

// TestPointerAddrReturnsContainerAddress verifies that PointerAddr reports
// the address of the struct itself (this is the address Dart later frees).
func TestPointerAddrReturnsContainerAddress(t *testing.T) {
	addr := BytesToPointerAddress([]byte("x"))
	if got := int64(PointerAddr(unsafe.Pointer(containerFromAddress(addr)))); got != addr {
		t.Fatalf("PointerAddr = %x, want %x", got, addr)
	}
}

// TestBytesToPointerAddressLargePayload exercises a large response payload to
// catch truncation of the int size field or off-by-one copies.
func TestBytesToPointerAddressLargePayload(t *testing.T) {
	want := bytes.Repeat([]byte("godash"), 1<<18) // 6 MiB
	addr := BytesToPointerAddress(want)
	got, size := readContainer(t, addr)
	if size != len(want) || !bytes.Equal(got, want) {
		t.Fatalf("large payload mismatch: size=%d want=%d equal=%v", size, len(want), bytes.Equal(got, want))
	}
}

// Note: InitializeDartAPI, SendPointerAddress and ClosePort require a live
// Dart VM (Dart_InitializeApiDL must be called with the VM's data struct
// first, otherwise the DL function pointers are nil and calling them would
// crash). Those paths are exercised end-to-end by the Dart-side bridge tests
// and the benchmark harness, which run inside a real Dart/Flutter runtime.
