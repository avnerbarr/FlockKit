<p align="center">
    <img src="Sources/FlockKit/Documentation.docc/Resources/Logo.png" alt="Project Icon" width="250" />
</p>

# FlockKit
 
A tiny Swift wrapper around POSIX `flock(2)` for ****cross-process**** file locking.
Use `FlockKit` when you need to ensure that ****only one process at a time**** runs a job or touches a file, without re-implementing lock files and race-prone shell scripts.

**Full documentation can be found [here](https://avnerbarr.github.io/FlockKit/documentation/flockkit)**

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
  - [Xcode](#xcode)
- [Quick start](#quick-start)
  - [Basic exclusive lock (blocking)](#basic-exclusive-lock-blocking)
  - [Non-blocking lock](#non-blocking-lock)
  - [Scoped helpers](#scoped-helpers)
    - [Exclusive (write) lock around a job](#exclusive-write-lock-around-a-job)
    - [Shared (read) lock](#shared-read-lock)
  - [Semantics & Caveats](#semantics--caveats)

## Features
- ✅ Simple, Swifty API over `flock(2)`
- ✅ Exclusive (write) and shared (read) locks
- ✅ Blocking and non-blocking acquisition
- ✅ Convenience helpers for “run this while locked”
- ✅ Linux + Darwin (macOS, iOS, tvOS, watchOS) friendly
- ⚠️ Designed for ****cross-process**** coordination, *_not_* intra-process thread safety

## Requirements
- **Swift**: Swift 5.9 or newer (adjust as appropriate)
- **Platforms**: Any platform that exposes POSIX `flock(2)` via:
  - `Darwin` (macOS, iOS, tvOS, watchOS)
  - `Glibc` (Linux)

## Installation

### Swift Package Manager

Add `FlockKit` as a dependency in your `Package.swift`:

```swift

// swift-tools-version: 5.9

import PackageDescription
let package = Package(
name: "YourApp",
dependencies: [
    .package(
        url: "https://github.com/avnerbarr/FlockKit.git",
        from: "0.1.0"
    )
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "FlockKit", package: "FlockKit")
        ]
    )
]
```
### Xcode

1. `File` -> `Add Packages...`
2. Enter the URL: `https://github.com/avnerbarr/FlockKit.git`
3. Select the latest version and add it to your target.

  

## Quick start

### Basic exclusive lock (blocking)

```swift
import FlockKit

do {
    let lock = try FileLock(path: "/tmp/myapp.lock")
    try lock.lockExclusive() // blocks until the lock is available
    defer { lock.unlock() }

    // Only one *process* at a time will reach this point.
    print("Running critical section…")
    // do important work
} catch {
    print("Failed to acquire lock: \(error)")
}
```


### Non-blocking lock

Use `blocking: false` to “try once and bail” instead of waiting:

```swift
import FlockKit

do {
    let lock = try FileLock(path: "/tmp/myapp.lock")
    try lock.lockExclusive(blocking: false)
    defer { lock.unlock() }
    print("We own the lock, running job…")
} catch let error as FlockKitError {
    switch error {
    case .lockFailed:
        print("Another instance is already running, exiting.")
    default:
        print("Lock error: \(error)")
    }
}
```

### Scoped helpers

If you just want to “run this closure while locked”, use the helper functions:

#### Exclusive (write) lock around a job

```swift
import FlockKit

do {
    let result = try withExclusiveWriteLock(at: "/tmp/myapp.job.lock") {
        try runJob()
    }
} catch let error as LockedJobError {
    switch error {
    case .flock(let lockError):
        print("Failed to acquire lock: \(lockError)")
    case .job(let jobError):
        print("Job failed while holding lock: \(jobError)")
    }
}
```
#### Shared (read) lock

```swift

import FlockKit

do {
    let result = try withSharedLock(at: "/tmp/myapp.cache.lock") {
        try loadCache()
    }
} catch let error as LockedJobError {
    switch error {
    case .flock(let lockError):
        print("Failed to acquire lock: \(lockError)")
    case .job(let jobError):
        print("Job failed while holding lock: \(jobError)")
    }
}
```

  

**Both helpers:**

- Create a new `FileLock` for the given path,
- Acquire the requested lock (exclusive or shared),
- Run your closure,
- Always call `unlock()` in a defer block,
- Wrap outcomes in `LockedJobError` so you know whether locking or the job failed.

## Semantics & Caveats

### **FlockKit is for cross-process mutual exclusion.** not per-thread synchronization

Locks are tracked by the OS **per process**, not per thread.

- If two **different** processes each create a `FileLock` for the same path and try to take an **exclusive** lock, only **one** will succeed at a time.
- If two **threads** in the **same process** each create their own `FileLock` for the **same path** and call `lockExclusive()`, both calls **can succeed**: the process already owns the lock, so the second `flock()` is effectively a no-op.

**It is not a general replacement for a mutex between threads in the same process.**

For thread-level synchronisation inside a single process, use standard Swift concurrency primitives:

* `DispatchQueue`
* `NSLock`
* `os_unfair_lock`
* `pthread_mutex_t`
* Swift concurrency (`actors`, etc.)


You can combine those with `FileLock` if you need both in-process and cross-process coordination.

**`FileLock` is not thread-safe**

The `FileLock` type keeps internal mutable state (`isLocked`) without any synchronisation. If you call its methods concurrently from multiple threads on the **same instance**, the behaviour is undefined and the internal bookkeeping may disagree with the OS lock.

If you must share a `FileLock` instance between threads, wrap all access in your own synchronisation (e.g. a serial `DispatchQueue` or `NSLock`).

### **Advisory locks**

`flock(2)` locks are **advisory**:

* **Other processes must also use** `flock()` (or `FlockKit`) on the same path for the lock to have effect. But you probably wrote those applications, so it shouldn't be a problem
* A process that ignores the lock and writes directly to the file is not prevented by the kernel from doing so.

### **Example: single-instance CLI tool**

A simple pattern for **“only one instance may run at a time”**:

```swift
import FlockKit

@main
struct MyTool {
    static func main() {
        do {
            try withExclusiveWriteLock(at: "/tmp/mytool.run.lock", blocking: false) {
                try runCommand()
            }
        } catch let error as LockedJobError {
            switch error {
            case .flock:
                fputs("Another instance is already running.\n", stderr)
                exit(1)
            case .job(let jobError):
                fputs("Command failed: \(jobError)\n", stderr)
                exit(2)
            }
        } catch {
            fputs("Unexpected error: \(error)\n", stderr)
            exit(3)
        }
    }
}
```

# License

FlockKit is licensed under the MIT License.
