import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

// MARK: - Error types

public enum FlockKitError: Error, CustomStringConvertible {
    case openFailed(path: String, errno: Errno)
    case lockFailed(path: String, errno: Errno)
    case doubleLockAttempt(path: String)
    public var description: String {
        switch self {
        case .openFailed(let path, let e):
            return "Failed to open lock file '\(path)': errno=\(e.rawValue) (\(e.description))"
        case .lockFailed(let path, let e):
            return "Failed to acquire lock on '\(path)': errno=\(e.rawValue) (\(e.description))"
        case .doubleLockAttempt(let path):
            return "Double lock attempt (using same lock object) on '\(path)'"
        }
    }
}

// MARK: - FileLock

/// A small wrapper around POSIX `flock()` for **cross-process** file locking.
///
/// This type is intended to coordinate *multiple processes* that all agree to use the same
/// lock-file path. The underlying lock is managed by the operating system and is:
///
/// - **Exclusive (write) lock**: only one process at a time may hold it.
/// - **Shared (read) lock**: multiple processes may hold it concurrently, as long as no
///   exclusive lock is held on the same file.
///
/// ### Important semantics
/// - Locks are **per process**, not per thread. From the OS’s point of view, a process
///   either holds a lock on the file or it does not; individual threads are not tracked.
/// - This means `FileLock` is **not a replacement for a mutex between threads** in the
///   same process. If two threads both call `lockExclusive()` (directly or via separate
///   `FileLock` instances), the OS will happily report success to both, because the
///   *process* already owns the lock.
/// - `FileLock` itself is **not thread-safe**: if you share a single instance between
///   threads, you must protect calls to its methods with your own in-process synchronization
///   (e.g. `NSLock`, `DispatchQueue`).
///
/// Use this type when you need:
/// - Mutual exclusion between **processes** (e.g. only one instance of a job/tool running),
/// - Or to guard access to a shared on-disk resource across multiple executables or daemons.
///
/// For **thread-level** synchronization *within a single process*, prefer standard
/// primitives such as `DispatchQueue`, `NSLock`, or `pthread_mutex_t`, and optionally
/// combine them with `FileLock` if you also need cross-process safety.
///
/// ### Example (exclusive, non-blocking)
/// ```swift
///
/// do {
///   let lock = try FileLock(path: "/tmp/myapp.job.lock")
///   try lock.lockExclusive()
///   // This process "won" the lock; safe to run the job here.
///   runJob()
/// } catch {
///       // another process is already running the job
/// }
/// ```
public final class FileLock {
    /// the path the lock is coordinating at
    public let path: String
    private let fd: Int32
    private var isLocked: Bool = false

    // MARK: - Init / deinit

    /// Opens (and creates, if needed) the lock file at `path`.
    ///
    /// The file itself is just a coordination point: its *contents* are irrelevant.
    public init(path: String) throws(FlockKitError) {
        self.path = path
        let flags = O_CREAT | O_RDWR // O_CREAT - Create the file if it does not exist, O_RDWR - open for both reading and writing
        let mode: mode_t = 0o666 // rw-rw-rw- (umask will trim)
        let fd = open(path, flags, mode)
        if fd == -1 {
            throw FlockKitError.openFailed(path: path, errno: Errno(errno: errno))
        }
        self.fd = fd
    }

    deinit {
        // Best-effort cleanup; ignore errors here.
        if isLocked {
            _ = flock(fd, LOCK_UN)
        }
        close(fd)
    }

    // MARK: - Public locking API

    /// Acquire a shared (read) lock.
    ///
    /// - Parameters:
    ///   - blocking: If `true`, wait until the lock is available.
    ///               If `false`, return immediately with an error if the lock is held.
    public func lockShared(blocking: Bool = true) throws(FlockKitError) {
        try lock(operation: LOCK_SH, blocking: blocking)
    }

    /// Acquire an exclusive (write) lock.
    ///
    /// - Parameters:
    ///   - blocking: If `true`, wait until the lock is available.
    ///               If `false`, return immediately with an error if the lock is held.
    public func lockExclusive(blocking: Bool = true) throws(FlockKitError) {
        try lock(operation: LOCK_EX, blocking: blocking)
    }

    /// Release any held lock (shared or exclusive).
    public func unlock() {
        if isLocked {
            _ = flock(fd, LOCK_UN)
            isLocked = false
        }
    }

    // MARK: - Private
    private func lock(operation: Int32, blocking: Bool) throws(FlockKitError) {
        // prevent double locking
        // guards against relocking
        guard !isLocked else {
            // Simple safety: prevent naive double-lock bugs.
            throw FlockKitError.doubleLockAttempt(path: path)
        }

        var op = operation
        if !blocking {
            op |= LOCK_NB // LOCK_NB = not blocking ,
        }

        if flock(fd, op) != 0 {
            throw FlockKitError.lockFailed(path: path, errno: Errno(errno: errno))
        }

        isLocked = true
    }
}

extension FileLock {
    
    /// Runs `body` while holding a shared process-wide lock on the given file.
    /// - Parameters:
    ///   - path: Path to the lock file used to coordinate between processes.
    ///   - blocking: if `true`, ait until the lock is available. If `false` and the lock is not acquired, will throw an exception
    ///   - body: Work to perform while the lock is held
    public class func withSharedLock<R>(_ path: String, blocking: Bool = true, _ body: () throws -> R) throws(LockedJobError) -> R {
        return try FlockKit.withSharedLock(at: path,blocking: blocking, body)
    }
    
    
    /// Runs `body` while holding an exclusive process-wide lock on the given file.
    ///
    /// - Parameters:
    ///   - path: Path to the lock file used to coordinate between processes.
    ///   - blocking: If `true`, wait until the lock is available. If `false`,
    ///               and the lock is not aquired will throw an exception
    ///   - body: Work to perform while the lock is held.
    /// - Returns: The value returned by `body`
    /// - Throws: `LockedJobError` if locking or body fails
    ///
    public class func withWriteLock<R>(_ path: String, blocking: Bool = true, _ body: () throws -> R) throws(LockedJobError) -> R {
        return try FlockKit.withExclusiveWriteLock(at: path, blocking: blocking, body)
    }
}

/// Represents an error when running a job
/// Error is either due to locking not succeeding, or the job failing
public enum LockedJobError: Error {
    case flock(FlockKitError)
    case job(Error)
}

/// Runs `body` while holding an exclusive process-wide lock on the given file.
///
/// - Parameters:
///   - path: Path to the lock file used to coordinate between processes.
///   - blocking: If `true`, wait until the lock is available. If `false`,
///               and the lock is not aquired will throw an exception
///   - body: Work to perform while the lock is held.
/// - Returns: The value returned by `body`
/// - Throws: `LockedJobError` if locking or body fails
///
@discardableResult
public func withExclusiveWriteLock<R>(
    at path: String,
    blocking: Bool = true,
    _ body: () throws -> R
) throws(LockedJobError) -> R {
    let lock: FileLock
    do {
        lock = try FileLock(path: path)
        try lock.lockExclusive(blocking: blocking)
    } catch {
        throw .flock(error)
    }
    defer {
        lock.unlock()
    }
    do {
        return try body()
    } catch {
        throw .job(error)
    }
}

/// Runs `body` while holding a shared process-wide lock on the given file.
///
/// - Parameters:
///   - path: Path to the lock file used to coordinate between processes.
///   - blocking: If `true`, wait until the lock is available. If `false`, will throw an exception if lock is not acquired
///   - body: Work to perform while the lock is held.
/// - Returns: The value returned by `body`
/// - Throws: `LockedJobError` if opening or locking fails
@discardableResult
public func withSharedLock<R>(
    at path: String,
    blocking: Bool = true,
    _ body: () throws -> R
) throws(LockedJobError) -> R {
    let lock: FileLock
    do {
        lock = try FileLock(path: path)
        try lock.lockShared(blocking: blocking)
    } catch {
        throw .flock(error)
    }
    
    defer {
        lock.unlock()
    }
    
    do {
        return try body()
    } catch {
        throw .job(error)
    }
}
