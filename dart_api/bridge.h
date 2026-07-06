#ifndef GO_DART_BRIDGE_H_
#define GO_DART_BRIDGE_H_

#include "dart_api_dl.h"

int64_t PointerAddr(void *ptr);
bool GoDart_PostCObject(Dart_Port_DL port, Dart_CObject *obj);
bool GoDart_PostPointerAddress(Dart_Port_DL port, int64_t ptrAddr);
bool GoDart_CloseNativePort(Dart_Port_DL port);

#endif