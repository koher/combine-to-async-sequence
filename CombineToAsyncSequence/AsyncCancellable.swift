final class AsyncCancellable: Hashable {
    private var _cancel: (() -> Void)?
    init(_ cancel: @escaping () -> Void) {
        self._cancel = cancel
    }
    func cancel() {
        _cancel?()
        _cancel = nil
    }
    deinit {
        _cancel?()
    }

    static func == (lhs: AsyncCancellable, rhs: AsyncCancellable) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
}

