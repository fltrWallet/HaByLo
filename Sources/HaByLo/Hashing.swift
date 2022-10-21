import struct CryptoKit.SHA256
import protocol Foundation.ContiguousBytes
import struct NIOCore.ByteBuffer

@inlinable
public func hash256(_ rbp: UnsafeRawBufferPointer) -> [UInt8] {
    Array(
        SHA256.hash(data: rbp).withUnsafeBytes { rbp in
            SHA256.hash(data: rbp)
        }
    )
}

@inlinable
public func sha256(_ rbp: UnsafeRawBufferPointer) -> [UInt8] {
    .init(SHA256.hash(data: rbp))
}

public extension Array where Element == UInt8 {
    @inlinable
    var hash256: [UInt8] {
        self.withUnsafeBytes(hash256(_:))
    }
    
    @inlinable
    var sha256: [UInt8] {
        self.withUnsafeBytes(sha256(_:))
    }
    
    @inlinable
    var checksum: UInt32 {
        self.hash256.withUnsafeBytes { $0.load(as: UInt32.self) }
    }
}

public extension ArraySlice where Element == UInt8 {
    @inlinable
    var hash256: [UInt8] {
        self.withUnsafeBytes(hash256(_:))
    }
    
    @inlinable
    var sha256: [UInt8] {
        self.withUnsafeBytes(sha256(_:))
    }
    
    @inlinable
    var checksum: UInt32 {
        self.hash256.withUnsafeBytes { $0.load(as: UInt32.self) }
    }
}

public extension ByteBuffer {
    @inlinable
    var hash256: [UInt8] {
        self.withUnsafeReadableBytes(hash256(_:))
    }
    
    @inlinable
    var sha256: [UInt8] {
        self.withUnsafeReadableBytes(sha256(_:))
    }
    
    @inlinable
    var checksum: UInt32 {
        self.hash256.withUnsafeBytes { $0.load(as: UInt32.self) }
    }
}

public extension ContiguousBytes {
    @inlinable
    var hash256: [UInt8] {
        self.withUnsafeBytes(hash256(_:))
    }

    @inlinable
    var sha256: [UInt8] {
        self.withUnsafeBytes(sha256(_:))
    }
    
    @inlinable
    var checksum: UInt32 {
        self.hash256.withUnsafeBytes { $0.load(as: UInt32.self) }
    }
}

public extension Sequence where Element == UInt8 {
    @inlinable
    var hash256: [UInt8] {
        self.withUnsafeRandomAccess(hash256(_:))
    }
    
    @inlinable
    var sha256: [UInt8] {
        self.withUnsafeRandomAccess(sha256(_:))
    }

    @inlinable
    var checksum: UInt32 {
        self.hash256.withUnsafeBytes { $0.load(as: UInt32.self) }
    }
}

public extension ByteBuffer {
    @inlinable
    mutating func readCVarInt<T: UnsignedInteger>(as: T.Type = T.self) -> T? {
        let save = self
        
        let maxWidth: T = T(MemoryLayout<T>.size - 1) * 8
        
        var result: T = 0
        while let nextByte = self.readInteger(as: UInt8.self) {
            // Overflow check
            guard result >> maxWidth == 0 else {
                return nil
            }
            
            result = (result << 7) | T(nextByte & 0x7F)
            if (nextByte & 0x80) > 0 {
                result += 1
            } else {
                return result
            }
        }
        
        self = save
        return nil
    }
}

public extension ByteBuffer {
    @inlinable
    mutating func readVarInt() -> UInt64? {
        let save = self
        
        let byte = self.readInteger(endianness: .little, as: UInt8.self).map { UInt64($0) }
        
        let readVarInt: UInt64?
        
        switch byte {
        case 0xfd?: readVarInt = self.readInteger(endianness: .little, as: UInt16.self).map { UInt64($0) }
        case 0xfe?: readVarInt = self.readInteger(endianness: .little, as: UInt32.self).map { UInt64($0) }
        case 0xff?: readVarInt = self.readInteger(endianness: .little, as: UInt64.self)
        default: readVarInt = byte
        }
        
        guard let result = readVarInt else {
            self = save
            return nil
        }
        
        return result
    }
}

// MARK: RipeMD160
public extension Array where Element == UInt8 {
    @inlinable
    var hash160: [UInt8] {
        self.sha256.ripeMd160()
    }

    @inlinable
    func ripeMd160() -> [UInt8] {
        var ripeMD160 = RipeMD160()
        ripeMD160.update(data: self[...])
        return ripeMD160.finalize()
    }
}

public extension ArraySlice where Element == UInt8 {
    @inlinable
    var hash160: [UInt8] {
        self.hash256.ripeMd160()
    }
    
    @inlinable
    func ripeMd160() -> [UInt8] {
        var ripeMD160 = RipeMD160()
        ripeMD160.update(data: self)
        return ripeMD160.finalize()
    }
}

public extension Sequence where Element == UInt8 {
    @inlinable
    var hash160: [UInt8] {
        self.hash256.ripeMd160()
    }
    
    @inlinable
    func ripeMd160() -> [UInt8] {
        var ripeMD160 = RipeMD160()
        ripeMD160.update(data: ArraySlice(self))
        return ripeMD160.finalize()
    }
}
