// Errno.swift
// Mapping of common POSIX error codes with explanations
// Generated for FlockKit

import Foundation

/// POSIX errno codes mapped to Swift with explanations.
public enum Errno: Int32, CustomStringConvertible, Sendable {
    /// Operation not permitted
    case EPERM = 1 // You do not have permission to perform the operation.
    /// No such file or directory
    case ENOENT = 2 // The specified file or directory does not exist.
    /// No such process
    case ESRCH = 3 // The specified process does not exist.
    /// Interrupted system call
    case EINTR = 4 // A signal interrupted the system call.
    /// I/O error
    case EIO = 5 // A low-level I/O error occurred.
    /// No such device or address
    case ENXIO = 6 // The device or address does not exist.
    /// Argument list too long
    case E2BIG = 7 // The argument list is too long for exec().
    /// Exec format error
    case ENOEXEC = 8 // The executable format is invalid.
    /// Bad file descriptor
    case EBADF = 9 // The file descriptor is not valid.
    /// No child processes
    case ECHILD = 10 // There are no child processes to wait for.
    /// Resource temporarily unavailable
    case EAGAIN = 11 // The resource is temporarily unavailable (try again).
    /// Cannot allocate memory
    case ENOMEM = 12 // Not enough memory is available.
    /// Permission denied
    case EACCES = 13 // You do not have permission to access the resource.
    /// Bad address
    case EFAULT = 14 // The address is invalid.
    /// Block device required
    case ENOTBLK = 15 // A block device is required.
    /// Device or resource busy
    case EBUSY = 16 // The device or resource is busy.
    /// File exists
    case EEXIST = 17 // The file already exists.
    /// Cross-device link
    case EXDEV = 18 // An attempt to make a cross-device link failed.
    /// No such device
    case ENODEV = 19 // The device does not exist.
    /// Not a directory
    case ENOTDIR = 20 // The specified path is not a directory.
    /// Is a directory
    case EISDIR = 21 // The specified path is a directory.
    /// Invalid argument
    case EINVAL = 22 // The argument is invalid.
    /// Too many open files in system
    case ENFILE = 23 // The system limit on open files has been reached.
    /// Too many open files
    case EMFILE = 24 // The process limit on open files has been reached.
    /// Inappropriate ioctl for device
    case ENOTTY = 25 // The ioctl request is inappropriate for the device.
    /// Text file busy
    case ETXTBSY = 26 // The text file is busy.
    /// File too large
    case EFBIG = 27 // The file is too large.
    /// No space left on device
    case ENOSPC = 28 // There is no space left on the device.
    /// Illegal seek
    case ESPIPE = 29 // An illegal seek was attempted.
    /// Read-only file system
    case EROFS = 30 // The file system is read-only.
    /// Too many links
    case EMLINK = 31 // There are too many links to the file.
    /// Broken pipe
    case EPIPE = 32 // The pipe is broken.
    /// Math argument out of domain of func
    case EDOM = 33 // A math function received an argument outside its domain.
    /// Math result not representable
    case ERANGE = 34 // The result of a math function is not representable.
    /// Resource temporarily unavailable (alias for EAGAIN)
    case EWOULDBLOCK = 35 // Operation would block (often same as EAGAIN).
    /// Operation now in progress
    case EINPROGRESS = 36 // Operation is now in progress.
    /// Operation already in progress
    case EALREADY = 37 // Operation is already in progress.
    /// Socket operation on non-socket
    case ENOTSOCK = 38 // Attempted socket operation on non-socket.
    /// Destination address required
    case EDESTADDRREQ = 39 // Destination address is required.
    /// Message too long
    case EMSGSIZE = 40 // Message is too long.
    /// Protocol wrong type for socket
    case EPROTOTYPE = 41 // Protocol is wrong type for socket.
    /// Protocol not available
    case ENOPROTOOPT = 42 // Protocol is not available.
    /// Protocol not supported
    case EPROTONOSUPPORT = 43 // Protocol is not supported.
    /// Socket type not supported
    case ESOCKTNOSUPPORT = 44 // Socket type is not supported.
    /// Operation not supported
    case EOPNOTSUPP = 45 // Operation is not supported.
    /// Protocol family not supported
    case EPFNOSUPPORT = 46 // Protocol family is not supported.
    /// Address family not supported by protocol family
    case EAFNOSUPPORT = 47 // Address family is not supported by protocol family.
    /// Address already in use
    case EADDRINUSE = 48 // Address is already in use.
    /// Cannot assign requested address
    case EADDRNOTAVAIL = 49 // Cannot assign requested address.
    /// Network is down
    case ENETDOWN = 50 // Network is down.
    /// Network is unreachable
    case ENETUNREACH = 51 // Network is unreachable.
    /// Network dropped connection on reset
    case ENETRESET = 52 // Network dropped connection on reset.
    /// Software caused connection abort
    case ECONNABORTED = 53 // Software caused connection abort.
    /// Connection reset by peer
    case ECONNRESET = 54 // Connection reset by peer.
    /// No buffer space available
    case ENOBUFS = 55 // No buffer space available.
    /// Socket is already connected
    case EISCONN = 56 // Socket is already connected.
    /// Socket is not connected
    case ENOTCONN = 57 // Socket is not connected.
    /// Can't send after socket shutdown
    case ESHUTDOWN = 58 // Can't send after socket shutdown.
    /// Too many references: can't splice
    case ETOOMANYREFS = 59 // Too many references: can't splice.
    /// Connection timed out
    case ETIMEDOUT = 60 // Connection timed out.
    /// Connection refused
    case ECONNREFUSED = 61 // Connection refused.
    /// Host is down
    case EHOSTDOWN = 64 // Host is down.
    /// No route to host
    case EHOSTUNREACH = 65 // No route to host.
    /// Directory not empty
    case ENOTEMPTY = 66 // Directory not empty.
    /// Too many processes
    case EPROCLIM = 67 // Too many processes.
    /// Stale NFS file handle
    case ESTALE = 70 // Stale NFS file handle.
    /// Object is remote
    case EREMOTE = 71 // Object is remote.
    /// Bad message
    case EBADMSG = 94 // Bad message.
    /// Identifier removed
    case EIDRM = 90 // Identifier removed.
    /// Multihop attempted
    case EMULTIHOP = 95 // Multihop attempted.
    /// No message available
    case ENOMSG = 91 // No message available.
    /// Function not implemented
    case ENOSYS = 78 // Function not implemented.
    /// Value too large for defined data type
    case EOVERFLOW = 84 // Value too large for defined data type.
    /// Unknown error
    case UNKNOWN = -1 // Unknown error code.

    /// Create from errno value
    public init(errno: Int32) {
        self = Errno(rawValue: errno) ?? .UNKNOWN
    }

    /// Human-readable description
    public var description: String {
        switch self {
        case .EPERM: return "Operation not permitted"
        case .ENOENT: return "No such file or directory"
        case .ESRCH: return "No such process"
        case .EINTR: return "Interrupted system call"
        case .EIO: return "I/O error"
        case .ENXIO: return "No such device or address"
        case .E2BIG: return "Argument list too long"
        case .ENOEXEC: return "Exec format error"
        case .EBADF: return "Bad file descriptor"
        case .ECHILD: return "No child processes"
        case .EAGAIN, .EWOULDBLOCK: return "Resource temporarily unavailable (would block)"
        case .ENOMEM: return "Cannot allocate memory"
        case .EACCES: return "Permission denied"
        case .EFAULT: return "Bad address"
        case .ENOTBLK: return "Block device required"
        case .EBUSY: return "Device or resource busy"
        case .EEXIST: return "File exists"
        case .EXDEV: return "Cross-device link"
        case .ENODEV: return "No such device"
        case .ENOTDIR: return "Not a directory"
        case .EISDIR: return "Is a directory"
        case .EINVAL: return "Invalid argument"
        case .ENFILE: return "Too many open files in system"
        case .EMFILE: return "Too many open files"
        case .ENOTTY: return "Inappropriate ioctl for device"
        case .ETXTBSY: return "Text file busy"
        case .EFBIG: return "File too large"
        case .ENOSPC: return "No space left on device"
        case .ESPIPE: return "Illegal seek"
        case .EROFS: return "Read-only file system"
        case .EMLINK: return "Too many links"
        case .EPIPE: return "Broken pipe"
        case .EDOM: return "Math argument out of domain of func"
        case .ERANGE: return "Math result not representable"
        case .EINPROGRESS: return "Operation now in progress"
        case .EALREADY: return "Operation already in progress"
        case .ENOTSOCK: return "Socket operation on non-socket"
        case .EDESTADDRREQ: return "Destination address required"
        case .EMSGSIZE: return "Message too long"
        case .EPROTOTYPE: return "Protocol wrong type for socket"
        case .ENOPROTOOPT: return "Protocol not available"
        case .EPROTONOSUPPORT: return "Protocol not supported"
        case .ESOCKTNOSUPPORT: return "Socket type not supported"
        case .EOPNOTSUPP: return "Operation not supported"
        case .EPFNOSUPPORT: return "Protocol family not supported"
        case .EAFNOSUPPORT: return "Address family not supported by protocol family"
        case .EADDRINUSE: return "Address already in use"
        case .EADDRNOTAVAIL: return "Cannot assign requested address"
        case .ENETDOWN: return "Network is down"
        case .ENETUNREACH: return "Network is unreachable"
        case .ENETRESET: return "Network dropped connection on reset"
        case .ECONNABORTED: return "Software caused connection abort"
        case .ECONNRESET: return "Connection reset by peer"
        case .ENOBUFS: return "No buffer space available"
        case .EISCONN: return "Socket is already connected"
        case .ENOTCONN: return "Socket is not connected"
        case .ESHUTDOWN: return "Can't send after socket shutdown"
        case .ETOOMANYREFS: return "Too many references: can't splice"
        case .ETIMEDOUT: return "Connection timed out"
        case .ECONNREFUSED: return "Connection refused"
        case .EHOSTDOWN: return "Host is down"
        case .EHOSTUNREACH: return "No route to host"
        case .ENOTEMPTY: return "Directory not empty"
        case .EPROCLIM: return "Too many processes"
        case .ESTALE: return "Stale NFS file handle"
        case .EREMOTE: return "Object is remote"
        case .EBADMSG: return "Bad message"
        case .EIDRM: return "Identifier removed"
        case .EMULTIHOP: return "Multihop attempted"
        case .ENOMSG: return "No message available"
        case .ENOSYS: return "Function not implemented"
        case .EOVERFLOW: return "Value too large for defined data type"
        case .UNKNOWN: return "Unknown error"
        }
    }
}
