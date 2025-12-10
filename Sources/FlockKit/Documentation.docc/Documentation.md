# ``FlockKit``

<!--@START_MENU_TOKEN@-->Summary<!--@END_MENU_TOKEN@-->

## Overview

<!--@START_MENU_TOKEN@-->Text<!--@END_MENU_TOKEN@-->

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->

```swift
enum Role: String {
    case reader
    case writer
    case tryWriter = "try-writer"
}

func runReader(lockPath: String) {
    do {
        let lock = try FileLock(path: lockPath)
        print("[reader] attempting shared lock…")
        try lock.lockShared()
        print("[reader] got shared lock, reading...")
        // Simulate work
        Thread.sleep(forTimeInterval: 5)
        print("[reader] done, unlocking")
        lock.unlock()
    } catch {
        print("[reader] error:", error)
    }
}

func runWriter(lockPath: String) {
    do {
        let lock = try FileLock(path: lockPath)
        print("[writer] attempting exclusive lock…")
        try lock.lockExclusive()
        print("[writer] got exclusive lock, writing...")
        // Simulate work
        Thread.sleep(forTimeInterval: 5)
        print("[writer] done, unlocking")
        lock.unlock()
    } catch {
        print("[writer] error:", error)
    }
}

func runTryWriter(lockPath: String) {
    do {
        let lock = try FileLock(path: lockPath)
        print("[try-writer] trying exclusive lock (non-blocking)…")
        let ok = try lock.tryLockExclusive()
        if ok {
            print("[try-writer] got lock, doing quick work...")
            Thread.sleep(forTimeInterval: 2)
            print("[try-writer] done, unlocking")
            lock.unlock()
        } else {
            print("[try-writer] lock is already held, skipping work")
        }
    } catch {
        print("[try-writer] error:", error)
    }
}
```
