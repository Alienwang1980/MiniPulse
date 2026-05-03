#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "battery" asset catalog image resource.
static NSString * const ACImageNameBattery AC_SWIFT_PRIVATE = @"battery";

/// The "bluetooth" asset catalog image resource.
static NSString * const ACImageNameBluetooth AC_SWIFT_PRIVATE = @"bluetooth";

/// The "cpu" asset catalog image resource.
static NSString * const ACImageNameCpu AC_SWIFT_PRIVATE = @"cpu";

/// The "disk" asset catalog image resource.
static NSString * const ACImageNameDisk AC_SWIFT_PRIVATE = @"disk";

/// The "gpu" asset catalog image resource.
static NSString * const ACImageNameGpu AC_SWIFT_PRIVATE = @"gpu";

/// The "logo_dark" asset catalog image resource.
static NSString * const ACImageNameLogoDark AC_SWIFT_PRIVATE = @"logo_dark";

/// The "logo_light" asset catalog image resource.
static NSString * const ACImageNameLogoLight AC_SWIFT_PRIVATE = @"logo_light";

/// The "logo_splash" asset catalog image resource.
static NSString * const ACImageNameLogoSplash AC_SWIFT_PRIVATE = @"logo_splash";

/// The "logo_splash_light" asset catalog image resource.
static NSString * const ACImageNameLogoSplashLight AC_SWIFT_PRIVATE = @"logo_splash_light";

/// The "machineInfo" asset catalog image resource.
static NSString * const ACImageNameMachineInfo AC_SWIFT_PRIVATE = @"machineInfo";

/// The "memory" asset catalog image resource.
static NSString * const ACImageNameMemory AC_SWIFT_PRIVATE = @"memory";

/// The "network" asset catalog image resource.
static NSString * const ACImageNameNetwork AC_SWIFT_PRIVATE = @"network";

/// The "power" asset catalog image resource.
static NSString * const ACImageNamePower AC_SWIFT_PRIVATE = @"power";

/// The "topCpu" asset catalog image resource.
static NSString * const ACImageNameTopCpu AC_SWIFT_PRIVATE = @"topCpu";

/// The "topMem" asset catalog image resource.
static NSString * const ACImageNameTopMem AC_SWIFT_PRIVATE = @"topMem";

/// The "usb" asset catalog image resource.
static NSString * const ACImageNameUsb AC_SWIFT_PRIVATE = @"usb";

#undef AC_SWIFT_PRIVATE
