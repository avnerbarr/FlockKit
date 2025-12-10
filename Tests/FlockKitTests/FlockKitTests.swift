import Testing
import Foundation
@testable import FlockKit

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

func getProductsDirectory() -> URL {
#if os(macOS)
    for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
        return bundle.bundleURL.deletingLastPathComponent()
    }
    fatalError("Couldn't find products directory")
#else
    Bundle.main.bundleURL.deletingLastPathComponent()
#endif
}

@Test func testExclusiveLockNonBlocking() async throws {
    let lockFile = "/tmp/flockkit_test.lock"
    let helperURL = getProductsDirectory().appendingPathComponent("LockTestHelper")
    print("Helper URL is: \(helperURL)")

    // Start first process: should acquire lock and hold for 2 seconds
    let proc1 = Process()
    proc1.executableURL = helperURL
    proc1.arguments = [lockFile, "exclusive", "blocking", "5"]
    let outPipe1 = Pipe()
    proc1.standardOutput = outPipe1
    print("starting proc 1")
    try proc1.run()
    print("sleeping for 1 second")
    sleep(1) // Give proc1 time to acquire lock
    print("starting proc 2")
    // Start second process: should fail to acquire lock (non-blocking)
    let proc2 = Process()
    proc2.executableURL = helperURL
    proc2.arguments = [lockFile, "exclusive", "nonblocking", "1"]
    let outPipe2 = Pipe()
    proc2.standardOutput = outPipe2
    try proc2.run()
    proc2.waitUntilExit()
    let output2 = String(data: outPipe2.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    print("output2: \(output2)")
    #expect(output2.contains("LOCK_FAILED"))
    #expect(proc2.terminationStatus == 1)

    proc1.waitUntilExit()
    let output1 = String(data: outPipe1.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    #expect(output1.contains("LOCKED_EXCLUSIVE"))
    #expect(output1.contains("UNLOCKED"))
    #expect(proc1.terminationStatus == 0)
}

@Test func testNonExclusiveLockNonBlocking() async throws {
    let lockFile = "/tmp/flockkit_test.lock"
    let helperURL = getProductsDirectory().appendingPathComponent("LockTestHelper")
    print("Helper URL is: \(helperURL)")

    // Start first process: should acquire lock and hold for 2 seconds
    let proc1 = Process()
    proc1.executableURL = helperURL
    proc1.arguments = [lockFile, "shared", "nonblocking", "2"]
    let outPipe1 = Pipe()
    proc1.standardOutput = outPipe1
    print("starting proc 1")
    try proc1.run()
    print("sleeping for 1 second")
    sleep(1) // Give proc1 time to acquire lock
    print("starting proc 2")
    // Start second process: should fail to acquire lock (non-blocking)
    let proc2 = Process()
    proc2.executableURL = helperURL
    proc2.arguments = [lockFile, "shared", "nonblocking", "1"]
    let outPipe2 = Pipe()
    proc2.standardOutput = outPipe2
    try proc2.run()
    proc2.waitUntilExit()
    let output2 = String(data: outPipe2.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    print("output2: \(output2)")
    #expect(output2.contains("LOCKED_SHARED"))
    #expect(proc2.terminationStatus == 0)

    proc1.waitUntilExit()
    let output1 = String(data: outPipe1.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    #expect(output1.contains("LOCKED_SHARED"))
    #expect(output1.contains("UNLOCKED"))
    #expect(proc1.terminationStatus == 0)
}
// Swift

@Test func testExclusiveLockBlocking() async throws {
    let lockFile = "/tmp/flockkit_test.lock"
    let helperURL = getProductsDirectory().appendingPathComponent("LockTestHelper")

    let proc1 = Process()
    proc1.executableURL = helperURL
    proc1.arguments = [lockFile, "exclusive", "blocking", "2"]
    let outPipe1 = Pipe()
    proc1.standardOutput = outPipe1
    try proc1.run()
    sleep(1)

    let proc2 = Process()
    proc2.executableURL = helperURL
    proc2.arguments = [lockFile, "exclusive", "blocking", "1"]
    let outPipe2 = Pipe()
    proc2.standardOutput = outPipe2
    try proc2.run()
    proc2.waitUntilExit()
    let output2 = String(data: outPipe2.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    #expect(output2.contains("LOCKED_EXCLUSIVE"))
    #expect(proc2.terminationStatus == 0)

    proc1.waitUntilExit()
    let output1 = String(data: outPipe1.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    #expect(output1.contains("LOCKED_EXCLUSIVE"))
    #expect(output1.contains("UNLOCKED"))
    #expect(proc1.terminationStatus == 0)
}

@Test func testSharedLockBlocking() async throws {
    let lockFile = "/tmp/flockkit_test.lock"
    let helperURL = getProductsDirectory().appendingPathComponent("LockTestHelper")

    let proc1 = Process()
    proc1.executableURL = helperURL
    proc1.arguments = [lockFile, "shared", "blocking", "2"]
    let outPipe1 = Pipe()
    proc1.standardOutput = outPipe1
    try proc1.run()
    sleep(1)

    let proc2 = Process()
    proc2.executableURL = helperURL
    proc2.arguments = [lockFile, "shared", "blocking", "1"]
    let outPipe2 = Pipe()
    proc2.standardOutput = outPipe2
    try proc2.run()
    proc2.waitUntilExit()
    let output2 = String(data: outPipe2.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    #expect(output2.contains("LOCKED_SHARED"))
    #expect(proc2.terminationStatus == 0)

    proc1.waitUntilExit()
    let output1 = String(data: outPipe1.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    #expect(output1.contains("LOCKED_SHARED"))
    #expect(output1.contains("UNLOCKED"))
    #expect(proc1.terminationStatus == 0)
}

@Test func testExclusiveLockBlockingReleased() async throws {
    let lockFile = "/tmp/flockkit_testtestExclusiveLockBlockingReleased.lock"
    let helperURL = getProductsDirectory().appendingPathComponent("LockTestHelper")
    let proc1 = Process()
    proc1.executableURL = helperURL
    proc1.arguments = [lockFile, "exclusive", "blocking", "2", "5"] // holds the lock for 2 seconds and then releases, but process will live additional 5 seconds, enough time to try to aquire the lock again
    let outPipe1 = Pipe()
    proc1.standardOutput = outPipe1
    try proc1.run()
    sleep(3) // sleep enough time to allow the lock to release

    let proc2 = Process()
    proc2.executableURL = helperURL
    proc2.arguments = [lockFile, "exclusive", "blocking", "1"]
    let outPipe2 = Pipe()
    proc2.standardOutput = outPipe2
    try proc2.run()
    proc2.waitUntilExit()
    let output2 = String(data: outPipe2.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    print("*************** output2: \(output2)")
    #expect(output2.contains("LOCKED_EXCLUSIVE"))
    #expect(output2.contains("UNLOCKED"))
    #expect(proc2.terminationStatus == 0)

    proc1.waitUntilExit()
    let output1 = String(data: outPipe1.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    #expect(output1.contains("LOCKED_EXCLUSIVE"))
    #expect(output1.contains("UNLOCKED"))
    #expect(proc1.terminationStatus == 0)
}
