# Quickstart Guide

Based on the provided codebase snippets, there are no explicit installation commands (such as CocoaPods, Swift Package Manager, or Carthage), build scripts, or environment variables documented.

Below are the header integration configurations directly indicated in the source code.

---

## Exposing Public Headers

### Exposing Headers to Swift (Bridging Header)
To expose Objective-C public headers to Swift within your project target, add the header imports to your bridging header file:

```objc
// Import public headers exposed to Swift
#import "FLEXManager.h"
```

### Framework Header Imports
If you are exposing public headers within a framework target (e.g., `ZLPhotoBrowser`), import public headers into the main umbrella header using framework module syntax:

```objc
#import <ZLPhotoBrowser/ZLWeakProxy.h>
```

---

## Environment Variables & Dependencies

* **Environment Variables:** None specified in the provided context.
* **Dependencies Identified in Context:** 
  * `ZLPhotoBrowser`
  * `SnapKit`

*Note: Further setup instructions, installation commands, and build configuration details are not available in the provided code snippets.*