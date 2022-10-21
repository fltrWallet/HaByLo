import os.log
import struct Foundation.Date
import class Foundation.DateComponentsFormatter
import class Foundation.NSString
import struct Foundation.TimeInterval

//private var _log_level_lock = os_unfair_lock()
//private var _log_level_value: LogLevel = .Log
//public var LOG_LEVEL: LogLevel {
//    get {
//        defer {
//            os_unfair_lock_unlock(&_log_level_lock)
//        }
//        os_unfair_lock_lock(&_log_level_lock)
//        return _log_level_value
//    }
//    set {
//        defer {
//            os_unfair_lock_unlock(&_log_level_lock)
//        }
//        os_unfair_lock_lock(&_log_level_lock)
//        _log_level_value = newValue
//    }
//}
#if DEBUG
public let logger: HaByLoLogger = {
    var print: Bool! = false

    print = true

    if print {
        return PrintLogger()
    } else {
        return NoLogger()
    }
}()
#else
public let logger = NoLogger()
#endif

public var LOG_LEVEL = LogLevel.Info

public struct NoLogger: HaByLoLogger {
    public func primaryLog(_ logLevel: LogLevel, _ msgfunc: () -> String, _ values: [Any?]) {
    }
}

public protocol HaByLoLogger {
    func primaryLog(_ logLevel: LogLevel, _ msgfunc: () -> String,
                    _ values: [ Any? ] )
}

public extension HaByLoLogger {
    @inlinable
    func error(_ msg: @autoclosure () -> String, _ values: Any?...) {
        primaryLog(.Error, msg, values)
    }
    @inlinable
    func warn (_ msg: @autoclosure () -> String, _ values: Any?...) {
        primaryLog(.Warn, msg, values)
    }
    @inlinable
    func log  (_ msg: @autoclosure () -> String, _ values: Any?...) {
        primaryLog(.Log, msg, values)
    }
    @inlinable
    func info (_ msg: @autoclosure () -> String, _ values: Any?...) {
        primaryLog(.Info, msg, values)
    }
    @inlinable
    func trace(_ msg: @autoclosure () -> String, _ values: Any?...) {
        primaryLog(.Trace, msg, values)
    }
}

public enum LogLevel : Int8 {
    case Error
    case Warn
    case Log
    case Info
    case Trace
    
    @usableFromInline
    var logPrefix : String {
        switch self {
        case .Error: return "ERROR: "
        case .Warn:  return "WARN:  "
        case .Info:  return "INFO:  "
        case .Trace: return "Trace: "
        case .Log:   return ""
        }
    }
}

extension LogLevel {
    @usableFromInline
    var osLogLevel: os.OSLogType {
        switch self {
        case .Error: return .error
        case .Warn: return .default
        case .Info: return .info
        // debug logging doesn't work rdar://47667447
        case .Trace: return .info
        case .Log: return .default
        }
    }
}

public struct PrintLogger : HaByLoLogger {
    @usableFromInline
    let _logLevel: LogLevel?
    @usableFromInline
    let osLog = OSLog(subsystem: "blix", category: "general")
    @usableFromInline
    var logLevel: LogLevel {
        return _logLevel ?? LOG_LEVEL
    }
    @usableFromInline
    let startTime: TimeInterval
    @inlinable
    public var elapsedTime: TimeInterval {
        Date().timeIntervalSinceReferenceDate - startTime
    }
    
    @inlinable
    public init(logLevel: LogLevel? = nil) {
        self.startTime = Date().timeIntervalSinceReferenceDate
        self._logLevel = logLevel
    }
    
    @inlinable
    public func primaryLog(_ logLevel : LogLevel,
                           _ msgfunc  : () -> String,
                           _ values   : [ Any? ] ) {
//        #if DEBUG
        guard logLevel.rawValue <= self.logLevel.rawValue else { return }
        
        let prefix = logLevel.logPrefix
        let s = msgfunc()
        let time = timeString(for: elapsedTime)
        
        if values.isEmpty {
            let staticString = "[\(time)]\(prefix)\(s)"
            os_log("%{public}@", log: osLog, type: logLevel.osLogLevel, staticString)
//            print("[\(time)]\(prefix)\(s)")
        } else {
            var ms = ""
            appendValues(values, to: &ms)
            let staticString = "[\(time)]\(prefix)\(s)\(ms)"
            os_log("%{public}@", log: osLog, type: logLevel.osLogLevel, staticString)
//            print("[\(time)]\(prefix)\(s)\(ms)")
        }
//        #endif
    }
    
    @usableFromInline
    func timeString(for interval: TimeInterval) -> String {
        let i = UInt64(interval)
        let (hours, hRemainder) = i.quotientAndRemainder(dividingBy: 3600)
        let (minutes, seconds) = hRemainder.quotientAndRemainder(dividingBy: 60)

        return "\(hours)h \(minutes)m \(seconds)s"
    }
    
    @usableFromInline
    func appendValues(_ values: [ Any? ], to ms: inout String) {
        for v in values {
            ms += " "
            if      let v = v as? CustomStringConvertible { ms += v.description }
            else if let v = v as? String                  { ms += v }
            else if let v = v                             { ms += "\(v)" }
            else                                          { ms += "<nil>" }
        }
    }
}

public final class LogKeyForLine {
    @usableFromInline
    let file: StaticString
    @usableFromInline
    let line: Int
    
    @inlinable
    public init(_ file: StaticString, _ line: Int) {
        self.file = file
        self.line = line
    }
}

@usableFromInline
func logHandleFor(subsystem: StaticString = "blixlib", line: Int = #line, category: StaticString = #fileID) -> (OSLog, OSSignpostID) {
    let subsystemString = "app.fltr." + String(describing: subsystem)
    let osLog = OSLog(subsystem: subsystemString, category: String(describing: category))
    let osSignpostId = OSSignpostID(log: osLog, object: LogKeyForLine(category, line))
    return (osLog, osSignpostId)
}

@inlinable
public func trace(event: String, number: Int? = nil, function: StaticString = #function, line: Int = #line, category: StaticString = #fileID) {
    let (osLog, id) = logHandleFor(line: line, category: category)
    os_signpost(.event, log: osLog, name: function, signpostID: id, "%s", event, (number ?? 0) as NSInteger)
}

@inlinable
public func trace<T>(begin message: StaticString = "%s",
                     function: StaticString = #function,
                     line: Int = #line,
                     category: StaticString = #fileID,
                     commands: () throws -> T) rethrows -> T {
    let (osLog, id) = logHandleFor(line: line, category: category)
    
    guard osLog.signpostsEnabled
    else {
        return try commands()
    }
    
    let signpostName = function
    os_signpost(.begin, log: osLog, name: signpostName, signpostID: id)
    let result = try commands()
    defer { os_signpost(.end, log: osLog, name: signpostName, signpostID: id, message, String(reflecting: result) as NSString) }
    return result
}

//@inlinable
//public func trace<T>(begin message: StaticString = "",
//                     function: StaticString = #function,
//                     line: Int = #line,
//                     category: StaticString = #filePath,
//                     commands: () throws -> T) rethrows -> T {
//    let (osLog, id) = logHandleFor(line: line, category: category)
//
//    guard osLog.signpostsEnabled
//    else {
//        return try commands()
//    }
//
//    let signpostName = function
//    os_signpost(.begin, log: osLog, name: signpostName, signpostID: id)
//    let result = try commands()
//    defer { os_signpost(.end, log: osLog, name: signpostName, signpostID: id, message) }
//    return result
//}
