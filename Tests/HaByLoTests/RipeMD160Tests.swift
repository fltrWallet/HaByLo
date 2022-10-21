import HaByLo
import XCTest

final class RipeMD160Tests: XCTestCase {
    func testRipeMD160() throws {
        var md = RipeMD160()
        
        func hash(_ string: String) -> Array<UInt8> {
            md.update(data: string.ascii[...])
            let result = md.finalize()
            return result
        }
        
        XCTAssertEqual(hash(""), "9c1185a5c5e9fc54612808977ee8f548b2258d31")
        XCTAssertEqual(hash("a"), "0bdc9d2d256b3ee9daae347be6f4dc835a467ffe")
        XCTAssertEqual(hash("abc"), "8eb208f7e05d987a9b044a8e98c6b087f15a0bfc")
        XCTAssertEqual(hash("message digest"), "5d0689ef49d2fae572b881b123a85ffa21595f36")
        XCTAssertEqual(hash("abcdefghijklmnopqrstuvwxyz"), "f71c27109c692c1b56bbdceb5b9d2865b3708dbc")
        XCTAssertEqual(hash("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"), "12a053384a9c0c88e405a06c27dcf49ada62eb2b")
        XCTAssertEqual(hash("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"), "b0e20b6e3116640286ed3a87a5713079b21f5189")

        let times8 = hash(
            (1...8).map { _ in
                "1234567890"
            }
            .joined()
        )
        XCTAssertEqual(times8, "9b752e45573d4b39f4dbd3323cab82bf63326bfb")

        let aMillion = hash(
            (1...1_000_000).map { _ in
                "a"
            }
            .joined()
        )
        XCTAssertEqual(aMillion, "52783243c1697bdbe16d37f97f68f08325dc1528")
    }
}

extension Array: ExpressibleByUnicodeScalarLiteral where Element == UInt8 {
    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self = String(value).hex2Bytes
    }
}

extension Array: ExpressibleByExtendedGraphemeClusterLiteral where Element == UInt8 {
    public init(extendedGraphemeClusterLiteral value: Character) {
        self = String(value).hex2Bytes
    }
}

extension Array: ExpressibleByStringLiteral where Element == UInt8 {
    public init(stringLiteral value: String) {
        self = value.hex2Bytes
    }
}
