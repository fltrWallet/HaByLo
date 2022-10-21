//===----------------------------------------------------------------------===//
//
// This source file is part of the fltrECC open source project
//
// Copyright (c) 2022 fltrWallet AG and the fltrECC project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import struct Foundation.CharacterSet
import struct NIOCore.ByteBufferView

// MARK: withUnsafeRandomAccess
public extension Sequence where Element == UInt8 {
    @inlinable
    func withUnsafeRandomAccess<R>(_ closure: (UnsafeRawBufferPointer) throws -> R ) rethrows -> R {
        try self.withContiguousStorageIfAvailable {
            try $0.withUnsafeBytes {
                try closure($0)
            }
        } ?? Array(self).withUnsafeBytes {
            try closure($0)
        }
    }
}

// MARK: hexEncodedString
public extension Sequence where Element == UInt8 {
    @inlinable
    var hexEncodedString: String {
        self.map { c in
            String(format: "%02hhx", c)
        }
        .joined()
    }
}

// MARK: String // hex2Bytes, hex2Hash, ascii
public extension StringProtocol {
    @inlinable
    var ascii: [UInt8] {
        compactMap {
            $0.asciiValue
        }
    }

    @inlinable
    var hex2Bytes: [UInt8] {
        let characters = Array(self)
        return stride(from: 0, to: self.count, by: 2).compactMap {
            UInt8(String(characters[$0...$0.advanced(by: 1)]), radix: 16)
        }
    }
    
    @inlinable
    func hex2Hash<To>(as: To.Type = To.self) -> BlockChain.Hash<To> {
        var index = self.startIndex
        let bytes: [UInt8] = stride(from: 0, to: self.count, by: 2).compactMap { _ in
            let nextIndex = self.index(after: index)
            let chars = self[index ... nextIndex]
            self.formIndex(&index, offsetBy: 2)
            return UInt8(chars, radix: 16)
        }
        return .init(.big(bytes))
    }

    @inlinable
    func isHex() -> Bool {
        var allowed = CharacterSet()
        allowed.insert(charactersIn: "0123456789abcdef")

        let lower = self.lowercased()
        guard self.count % 2 == 0,
              lower.unicodeScalars.allSatisfy({ allowed.contains($0) })
        else {
            return false
        }
        
        return true
    }
}
