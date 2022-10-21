import HaByLo
import XCTest

final class BlockChainTests: XCTestCase {
    
    override func setUp() {
    }
    
    override func tearDown() {
    }

    func testHashComparable() {
        let block1_722_094Hash: BlockChain.Hash<BlockHeaderHash> = "000000000000012ecc7c92ab495125bf2539607b836830a47a3a5d145304d14a".hex2Hash()
        let block1_722_097Hash: BlockChain.Hash<BlockHeaderHash> = "00000000004d6370ab8d39f3e221354cb4940b042c700ab88e7ad20d72ca2d78".hex2Hash()
        let block1_722_224Hash: BlockChain.Hash<BlockHeaderHash> = "000000001b3e04061a9baec74f84fff9177833b3df5d0ded65dc331782af1c5b".hex2Hash()
        XCTAssertFalse(block1_722_094Hash < block1_722_094Hash)
        XCTAssertTrue(block1_722_094Hash < block1_722_097Hash)
        XCTAssertTrue(block1_722_094Hash < block1_722_224Hash)
        XCTAssertFalse(block1_722_097Hash < block1_722_094Hash)
        XCTAssertFalse(block1_722_097Hash < block1_722_097Hash)
        XCTAssertTrue(block1_722_097Hash < block1_722_224Hash)
        XCTAssertFalse(block1_722_224Hash < block1_722_094Hash)
        XCTAssertFalse(block1_722_224Hash < block1_722_097Hash)
        XCTAssertFalse(block1_722_224Hash < block1_722_224Hash)
    }

    func testHashEquatable() {
        let block1_722_094Hash: BlockChain.Hash<BlockHeaderHash> = "000000000000012ecc7c92ab495125bf2539607b836830a47a3a5d145304d14a".hex2Hash()
        let block1_722_097Hash: BlockChain.Hash<BlockHeaderHash> = "00000000004d6370ab8d39f3e221354cb4940b042c700ab88e7ad20d72ca2d78".hex2Hash()
        let block1_722_224Hash: BlockChain.Hash<BlockHeaderHash> = "000000001b3e04061a9baec74f84fff9177833b3df5d0ded65dc331782af1c5b".hex2Hash()
        XCTAssertTrue(block1_722_094Hash == block1_722_094Hash)
        XCTAssertFalse(block1_722_094Hash == block1_722_097Hash)
        XCTAssertFalse(block1_722_094Hash == block1_722_224Hash)
        XCTAssertFalse(block1_722_097Hash == block1_722_094Hash)
        XCTAssertTrue(block1_722_097Hash == block1_722_097Hash)
        XCTAssertFalse(block1_722_097Hash == block1_722_224Hash)
        XCTAssertFalse(block1_722_224Hash == block1_722_094Hash)
        XCTAssertTrue(block1_722_224Hash == block1_722_224Hash)
    }
    
    func testHashHashable() {
        let block1_722_094Hash: BlockChain.Hash<BlockHeaderHash> = "000000000000012ecc7c92ab495125bf2539607b836830a47a3a5d145304d14a"
        let block1_722_097Hash: BlockChain.Hash<BlockHeaderHash> = "00000000004d6370ab8d39f3e221354cb4940b042c700ab88e7ad20d72ca2d78"
        let block1_722_224Hash: BlockChain.Hash<BlockHeaderHash> = "000000001b3e04061a9baec74f84fff9177833b3df5d0ded65dc331782af1c5b"
        XCTAssertEqual(block1_722_094Hash.hashValue, Int(bitPattern: 0x7a3a5d145304d14a).byteSwapped.hashValue)
        XCTAssertEqual(block1_722_097Hash.hashValue, Int(bitPattern: 0x8e7ad20d72ca2d78).byteSwapped.hashValue)
        XCTAssertEqual(block1_722_224Hash.hashValue, Int(bitPattern: 0x65dc331782af1c5b).byteSwapped.hashValue)
    }
    
    func testExpressibleByIntegerArrayLiteral() {
        let zeroHash: BlockChain.Hash<BlockHeaderHash> = .zero
        XCTAssertEqual(0, zeroHash)
        
        let bigEndian: BlockChain.Hash<BlockHeaderHash> = "0000000000000000000000000000000000000000000000007a3a5d145304d14a"
        XCTAssertEqual(bigEndian, 0x7a3a5d145304d14a)
    }
    
    enum TestTag: TaggedHash {
        static var tag: [UInt8] = "testing".utf8.sha256
    }
    
    func testTagged() {
        let message = "message".utf8
        let hash: BlockChain.Hash<TestTag> = .makeHash(from: message)
        
        XCTAssertEqual(hash, "cc39a7d0713aa5f3942ac1e05e2a1e5241148cb0e5325afac4388bab2df7a25e")
    }
}
