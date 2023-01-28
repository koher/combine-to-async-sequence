import Combine

extension Task {
    func store(in cancellables: inout Set<AnyCancellable>) {
        cancellables.insert(.init { cancel() })
    }

    func store(in cancellables: inout Set<AsyncCancellable>) {
        cancellables.insert(.init { cancel() })
    }
}
