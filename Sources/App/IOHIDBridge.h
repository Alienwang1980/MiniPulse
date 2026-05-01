//
//  IOHIDBridge.h
//  MiniPulse
//
//  IOHIDEventSystemClient C function declarations for Apple Silicon temperature reading
//  Reference: Stats.app by exelban (MIT License)
//

#ifndef IOHIDBridge_h
#define IOHIDBridge_h

#include <CoreFoundation/CoreFoundation.h>

// IOHIDEventSystemClient types (opaque pointers)
typedef struct __IOHIDEventSystemClient * IOHIDEventSystemClientRef;
typedef struct __IOHIDServiceClient * IOHIDServiceClientRef;
typedef struct __IOHIDEvent * IOHIDEventRef;

#ifdef __LP64__
typedef double IOHIDFloat;
#else
typedef float IOHIDFloat;
#endif

// IOHIDEventSystemClient functions
extern IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);
extern int IOHIDEventSystemClientSetMatching(IOHIDEventSystemClientRef client, CFDictionaryRef match);
extern CFArrayRef IOHIDEventSystemClientCopyServices(IOHIDEventSystemClientRef client);

// IOHIDServiceClient functions
extern CFTypeRef IOHIDServiceClientCopyProperty(IOHIDServiceClientRef service, CFStringRef property);
extern IOHIDEventRef IOHIDServiceClientCopyEvent(IOHIDServiceClientRef service, int64_t type, int32_t unused1, int64_t unused2);

// IOHIDEvent functions
extern IOHIDFloat IOHIDEventGetFloatValue(IOHIDEventRef event, int32_t field);

// Event type constants
static const int32_t kIOHIDEventTypeTemperatureConst = 15;
static const int32_t kIOHIDEventTypePowerConst = 25;

// Helper to get event field base
static inline int32_t IOHIDEventFieldBaseFunc(int32_t type) { return type << 16; }

#endif /* IOHIDBridge_h */
