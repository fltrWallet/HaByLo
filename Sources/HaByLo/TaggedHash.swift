public protocol TaggedHash {
    static var tag: [UInt8] { get }
}

public extension BlockChain.Hash where HashType: TaggedHash {
    @inlinable
    static func makeHash<Stream: Collection>(from stream: Stream) -> BlockChain.Hash<HashType> where Stream.Element == UInt8 {
        Self(
            .little(
                [ HashType.tag, HashType.tag + stream, ]
                    .joined()
                    .sha256
            )
        )
    }

    @inlinable
    static func makeHash<Stream: Sequence>(from stream: Stream) -> BlockChain.Hash<HashType> where Stream.Element == UInt8 {
        stream.withUnsafeRandomAccess { bp in
            Self.makeHash(from: bp)
        }
    }
}
