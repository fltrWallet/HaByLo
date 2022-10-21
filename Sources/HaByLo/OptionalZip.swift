@inlinable
public func zip<W>(_ lhs: Optional<W>, _ rhs: Optional<W>) -> Optional<(W, W)> {
    lhs.flatMap { lhs in
        rhs.map { rhs in
            (lhs, rhs)
        }
    }
}
