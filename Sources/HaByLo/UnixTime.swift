import CoreFoundation

@inlinable
public func unixTimeInSeconds() -> UInt64 {
    UInt64(unixTime())
}

@inlinable
public func unixTime() -> Double {
    CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970
}
