import HaByLo
import NIOCore
import XCTest

final class CVarIntExtensionTests: XCTestCase {
    var allocator: ByteBufferAllocator!
    var testBuffer: ByteBuffer!
    
    let testCVarIntBytes: [UInt64 : [UInt8]] = [
        0 : [0x00],
        1 : [0x01],
        127 : [0x7F],
        128 : [0x80, 0x00],
        255 : [0x80, 0x7F],
        256 : [0x81, 0x00],
        2288 : [0x90, 0x70],
        16383 : [0xFE, 0x7F],
        16384 : [0xFF, 0x00],
        16511 : [0xFF, 0x7F],
        65535 : [0x82, 0xFE, 0x7F],
        4_294_967_296 : [0x8E, 0xFE, 0xFE, 0xFF, 0x00],
        1_152_921_508_901_814_399 : [0x8E, 0xFE, 0xFE, 0xFF, 0x8E, 0xFE, 0xFE, 0xFF, 0x7F],
    ]
    
    override func setUp() {
        self.allocator = ByteBufferAllocator()
        self.testBuffer = self.allocator.buffer(capacity: 32)
        
        self.testCVarIntBytes.forEach {
            self.testBuffer.writeBytes($0.value)
        }
    }
    
    override func tearDown() {
        self.testBuffer = nil
        self.allocator = nil
    }
    
    func testReads() {
        while let i: UInt64 = self.testBuffer.readCVarInt() {
            XCTAssertNotNil(self.testCVarIntBytes[i])
        }
        if self.testBuffer.readableBytes > 0 {
            XCTFail()
        }
    }
    
    func testWrites() {
        self.testCVarIntBytes.forEach {
            XCTAssertEqual($0.key.cVarInt, self.testCVarIntBytes[$0.key])
        }
    }
    
    func testWriteReadBack() {
        self.testCVarIntBytes.forEach {
            var buffer = self.allocator.buffer(capacity: 10)
            buffer.writeBytes($0.key.cVarInt)
            let result: UInt64? = buffer.readCVarInt()
            XCTAssertNotNil(result)
            XCTAssertEqual(result, $0.key)
        }
    }
    
    func testOverflow() {
        var singleByteBuffer = self.allocator.buffer(capacity: 1)
        singleByteBuffer.writeBytes([0x01])
        XCTAssertEqual(singleByteBuffer.readCVarInt(as: UInt8.self), 1)
        
        guard let overflowBytes = self.testCVarIntBytes[4_294_967_296] else {
            XCTFail()
            return
        }
        var overflowBuffer = self.allocator.buffer(capacity: 8)
        overflowBuffer.writeBytes(overflowBytes)
        let save = overflowBuffer
        XCTAssertNil(overflowBuffer.readCVarInt(as: UInt8.self))
        overflowBuffer = save
        XCTAssertNil(overflowBuffer.readCVarInt(as: UInt16.self))
        overflowBuffer = save
        XCTAssertNil(overflowBuffer.readCVarInt(as: UInt32.self))
        overflowBuffer = save
        XCTAssertEqual(overflowBuffer.readCVarInt(as: UInt64.self), 4_294_967_296)
        
        guard let overflow2Bytes = self.testCVarIntBytes[1_152_921_508_901_814_399] else {
            XCTFail()
            return
        }
        var overflow2Buffer = self.allocator.buffer(capacity: 10)
        overflow2Buffer.writeBytes(overflow2Bytes)
        let save2 = overflow2Buffer
        XCTAssertNil(overflow2Buffer.readCVarInt(as: UInt8.self))
        overflow2Buffer = save2
        XCTAssertNil(overflow2Buffer.readCVarInt(as: UInt16.self))
        overflow2Buffer = save2
        XCTAssertNil(overflow2Buffer.readCVarInt(as: UInt32.self))
        overflow2Buffer = save2
        XCTAssertEqual(overflow2Buffer.readCVarInt(as: UInt64.self), 1_152_921_508_901_814_399)
    }
}
