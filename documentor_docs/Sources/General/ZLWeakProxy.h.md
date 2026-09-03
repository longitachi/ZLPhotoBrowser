# Technical Documentation: `ZLWeakProxy.h`

## Overview

The `ZLWeakProxy.h` header file defines `ZLWeakProxy`, a class inheriting from `NSObject` that acts as a wrapper around a weakly referenced target object. This utility is commonly used in Objective-C and Swift codebases to hold weak references to objects, such as targets in target-action patterns or timers (`NSTimer` / `CADisplayLink`), thereby preventing strong reference cycles (memory leaks).

---

## Header Specifications

* **File Path:** `Sources/General/ZLWeakProxy.h`
* **Framework Import:** `<Foundation/Foundation.h>`
* **Nullability Annotation:** Wraps the entire header in `NS_ASSUME_NONNULL_BEGIN` and `NS_ASSUME_NONNULL_END`.

---

## Class Interface

```objc
@interface ZLWeakProxy : NSObject
```

### Properties

#### `target`

```objc
@property (nonatomic, weak, readonly, nullable) id target;
```

* **Description:** Holds a weak reference to the underlying target object wrapped by the proxy.
* **Attributes:**
  * `nonatomic`: Accessors are not thread-safe locked.
  * `weak`: The proxy does not retain the target object. When the target object is deallocated, this property automatically becomes `nil`.
  * `readonly`: The `target` cannot be reassigned after the proxy is initialized.
  * `nullable`: The property may evaluate to `nil` if the target has been deallocated or was not retained elsewhere.

---

### Method Declarations

#### Initializer

```objc
- (nonnull instancetype)initWithTarget:(nonnull id)target NS_SWIFT_NAME(init(target:));
```

* **Description:** Initializes a new instance of `ZLWeakProxy` with a specified target object.
* **Parameters:**
  * `target`: A non-null object reference (`id`) to be weakly held by the proxy instance.
* **Return Value:** An initialized instance of `ZLWeakProxy` (`nonnull instancetype`).
* **Swift Interoperability:** Custom named in Swift as `init(target:)`.

---

#### Factory Method

```objc
+ (nonnull instancetype)proxyWithTarget:(nonnull id)target NS_SWIFT_NAME(proxy(target:));
```

* **Description:** A class factory method that constructs and returns a new instance of `ZLWeakProxy` wrapping the provided target.
* **Parameters:**
  * `target`: A non-null object reference (`id`) to be weakly held by the proxy instance.
* **Return Value:** A newly created instance of `ZLWeakProxy` (`nonnull instancetype`).
* **Swift Interoperability:** Custom named in Swift as `ZLWeakProxy.proxy(target:)`.

---

## Swift Interoperability Summary

The header includes explicit Swift naming annotations (`NS_SWIFT_NAME`) to ensure idiomatic usage within Swift codebases:

| Objective-C Declaration | Swift Name |
| :--- | :--- |
| `- initWithTarget:` | `ZLWeakProxy(target:)` |
| `+ proxyWithTarget:` | `ZLWeakProxy.proxy(target:)` |