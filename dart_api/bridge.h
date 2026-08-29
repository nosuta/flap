#ifndef GO_DART_BRIDGE_H_
#define GO_DART_BRIDGE_H_

#include "dart_api_dl.h"

// Cross-heap allocator contract:
// - Request containers are allocated by Dart and freed by Dart.
// - Response/push containers are allocated on the Go side (C.malloc /
//   C.CBytes in BytesToPointerAddress) and freed by Dart *through* this
//   function (exposed to Dart via the Go-exported `FreeBytesContainer`
//   symbol), so the C allocator that allocated them also frees them.
void GoDash_FreeBytesContainer(void *ptr);

int64_t PointerAddr(void *ptr);
bool GoDart_PostCObject(Dart_Port_DL port, Dart_CObject *obj);
bool GoDart_PostPointerAddress(Dart_Port_DL port, int64_t ptrAddr);
bool GoDart_CloseNativePort(Dart_Port_DL port);

#endif