#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include "dart_api_dl.h"
#include "bridge.h"

// Mirror of the bytesContainer struct declared in the cgo preambles
// (dart_api/bridge.go and the generated go/main.go). Layout on 64-bit
// targets: message at offset 0, size at offset 8.
typedef struct bytesContainer
{
    void *message;
    int size;
} BytesContainer;

void GoDash_FreeBytesContainer(void *ptr)
{
    if (ptr == NULL)
    {
        return;
    }
    BytesContainer *bc = (BytesContainer *)ptr;
    if (bc->message != NULL)
    {
        free(bc->message);
        bc->message = NULL;
    }
    free(bc);
}

int64_t PointerAddr(void *ptr)
{
    int64_t p = (int64_t)ptr;
    return p;
}

bool GoDart_PostCObject(Dart_Port_DL port, Dart_CObject *obj)
{
    return Dart_PostCObject_DL(port, obj);
}

bool GoDart_PostPointerAddress(Dart_Port_DL port, int64_t ptrAddr)
{
    Dart_CObject dartObj;
    dartObj.type = Dart_CObject_kInt64;

    dartObj.value.as_int64 = ptrAddr;

    return Dart_PostCObject_DL(port, &dartObj);
}

bool GoDart_CloseNativePort(Dart_Port_DL port)
{
    return Dart_CloseNativePort_DL(port);
}
