# Technical Documentation: `Sources/ZLPhotoBrowser.h`

## Overview

The `ZLPhotoBrowser.h` file serves as the primary **umbrella header** for the `ZLPhotoBrowser` framework. It defines the public C/Objective-C symbol exports for framework versioning and imports the public headers necessary for consumers of the library.

---

## Header Metadata

* **File Path:** `Sources/ZLPhotoBrowser.h`
* **Author:** Long Zhang (`495181165@qq.com`)
* **Creation Date:** August 11, 2020
* **License:** MIT License

---

## Key Components

### 1. License and Copyright Header
The top section of the file contains the standard MIT License notice. It grants permission to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, provided the copyright notice and permission notice are retained.

### 2. Framework Imports

```objc
#import <Foundation/Foundation.h>
#import <ZLPhotoBrowser/ZLWeakProxy.h>
```

* `<Foundation/Foundation.h>`: Imports standard Foundation library types, macros, and protocols required by Apple platforms.
* `<ZLPhotoBrowser/ZLWeakProxy.h>`: Imports the public header `ZLWeakProxy.h`, making it accessible to consumers of the `ZLPhotoBrowser` module.

### 3. Framework Version Identifiers

```objc
FOUNDATION_EXPORT double ZLPhotoBrowserVersionNumber;
FOUNDATION_EXPORT const unsigned char ZLPhotoBrowserVersionString[];
```

The header declares two exported global variables for checking the framework version programmatically:

* **`ZLPhotoBrowserVersionNumber`** (`double`): A numeric representation of the current framework version.
* **`ZLPhotoBrowserVersionString`** (`const unsigned char[]`): A C-string representation of the current framework version.

Both symbols use the `FOUNDATION_EXPORT` macro to ensure proper C-linkage and symbol visibility across library boundaries.

---

## How It Works

When `ZLPhotoBrowser` is integrated as a framework into an iOS/macOS/Apple platform project:

1. **Module Import:** Including `#import <ZLPhotoBrowser/ZLPhotoBrowser.h>` (or `import ZLPhotoBrowser` in Swift) imports this header.
2. **Public Interface Exposure:** Any public headers listed via `#import <ZLPhotoBrowser/HeaderName.h>` (currently `ZLWeakProxy.h`) are exposed to the calling target.
3. **Version Querying:** External code can read `ZLPhotoBrowserVersionNumber` or `ZLPhotoBrowserVersionString` at runtime to inspect the framework version.