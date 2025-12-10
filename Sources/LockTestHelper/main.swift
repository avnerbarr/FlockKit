import FlockKit
import Foundation

func main() {
    let args = CommandLine.arguments
    if args.count < 5 {
        print("Usage: LockTestHelper <lockfile> <exclusive|shared> <blocking|nonblocking> <holdSeconds> <waitSecondsToExitAfterLockReleased>")
        exit(2)
    }
    let path = args[1]
    let mode = args[2]
    let blocking = args[3] == "blocking"
    let holdSeconds = Int(args[4]) ?? 1
    let waitUntilExitSeconds = Int(args.count > 5 ? args[5] : "0") ?? 0

    do {
        if mode == "exclusive" {
            try withExclusiveWriteLock(at: path, blocking: blocking) {
                print("LOCKED_EXCLUSIVE")
                fflush(stdout)
                sleep(UInt32(holdSeconds))
            }
        } else {
            try withSharedLock(at: path, blocking: blocking) {
                print("LOCKED_SHARED")
                fflush(stdout)
                sleep(UInt32(holdSeconds))
            }
        }
        if waitUntilExitSeconds > 0 {
            sleep(UInt32(waitUntilExitSeconds))
        }
        print("UNLOCKED")
        exit(0)
    } catch {
        print("LOCK_FAILED: \(error)")
        exit(1)
    }
}

main()
