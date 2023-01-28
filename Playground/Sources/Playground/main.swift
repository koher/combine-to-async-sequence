import Foundation
import AsyncAlgorithms
import Combine

//protocol Sequence {
//    associatedtype Iterator: IteratorProtocol
//    func makeIterator() -> Iterator
//}
//


//let array: Array<Int> = [2, 3, 5]
//
//var iterator = array.makeIterator()
//while let element = iterator.next() {
//    print(element)
//}

//for element in array {
//    print(element)
//}

//let range: Range<Int> = 0 ..< 100
//
//var iterator = range.makeIterator()
//while let i = iterator.next() {
//    print(i)
//}

//for i in range {
//    print(i)
//}

//protocol IteratorProtocol {
//    associatedtype Element
//    func next() -> Element?
//}
//
//protocol AsyncIteratorProtocol {
//    associatedtype Element
//    func next() async throws -> Element?
//}
//
//let url: URL = .init(string: "https://koherent.org/pi/pi1000000.txt")!
//let characters = url.resourceBytes.characters
//
//var iterator = characters.makeAsyncIterator()
//while let character = try await iterator.next() {
//    print(character, terminator: "")
//}

//for try await character in characters {
//    print(character, terminator: "")
//}

//var sender: AsyncStream<Int>.Continuation?
//let values: AsyncStream<Int> = .init { continuation in
////    sender = continuation
//    Task {
//        try? await Task.sleep(nanoseconds: 1_000_000_000)
//        continuation.yield(2)
//        try? await Task.sleep(nanoseconds: 1_000_000_000)
//        continuation.yield(3)
//        try? await Task.sleep(nanoseconds: 1_000_000_000)
//        continuation.yield(5)
//    }
//}

//Task {
//    try? await Task.sleep(nanoseconds: 1_000_000_000)
//    sender?.yield(2)
//    try? await Task.sleep(nanoseconds: 1_000_000_000)
//    sender?.yield(3)
//    try? await Task.sleep(nanoseconds: 1_000_000_000)
//    sender?.yield(5)
//}
//
//for await value in values {
//    print(value)
//}


let values: AsyncThrowingStream<Int, Error> = .init { continuation in
    Task {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        continuation.yield(2)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        continuation.yield(3)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        continuation.yield(5)
    }
}
//
//for try await value in values {
//    print(value)
//}

//let subject: CurrentValueSubject<Int, Never> = .init(42)
//
//var cancellables: Set<AnyCancellable> = []
//
//subject.sink { value in
//    print(value)
//}
//.store(in: &cancellables)
//
//subject.value = 999

//final class AsyncStore<Value: Sendable>: AsyncSequence {
//    typealias Element = Value
//
//    var value: Value {
//        didSet {
//            let channel = self.channel
//            let value = self.value
//            Task {
//                await channel.send(value)
//            }
//        }
//    }
//    private let channel: AsyncChannel<Value> = .init()
//    init(_ value: Value) {
//        self.value = value
//    }
//
//    func makeAsyncIterator() -> AsyncChannel<Value>.AsyncIterator {
//        channel.makeAsyncIterator()
//    }
//}
//
//let store: AsyncStore<Int> = .init(42)
//
//let task = Task {
//    print("B")
//    for await value in store {
//        print(value)
//    }
//}
//
//print("A")
//store.value = 999
//store.value = 998
//
//
//await task.value



//func foo(_ f: () throws -> Int) rethrows {
//
//}
//
//func w() throws -> Int { 42 }
//func v() -> Int { 42 }
//
//try foo(w)
//foo(v)


@rethrows
protocol P {
    func foo() throws -> Int
}

@rethrows
protocol Q {
    associatedtype X: P

    func bar() throws -> Int
    func x() -> X
}

struct A: P {
    func foo() throws -> Int { 42 }
}

struct B: P {
    func foo() -> Int { 42 }
}

struct C: Q {
    func bar() throws -> Int { 999 }
    func x() -> A { A() }
}

struct D: Q {
    func bar() -> Int { 999 }
    func x() -> B { B() }
}

//let p = A()
//print(try p.foo())

//let p = B()
//print(p.foo())


//func useP<X: P>(_ p: X) rethrows {
//    print(try p.foo())
//}
//
//try useP(A())
//useP(B())
//
//func useQ<Y: Q>(_ q: Y) rethrows {
//    print(try q.x().foo())
//}
//
//try useQ(C())
//useQ(D())


//@rethrows
//protocol AsyncIteratorProtocol {
//    associatedtype Element
//    mutating func next() async throws -> Element
//}
//
//@rethrows
//protocol AsyncSequence {
//    associatedtype AsyncIterator: AsyncIteratorProtocol
//    func makeAsyncIterator() -> AsyncIterator
//}

func forEach<S: AsyncSequence>(of sequence: S, body: @escaping (S.Element) -> Void) async rethrows {
    var iterator = sequence.makeAsyncIterator()
    while let element = try await iterator.next() {
        body(element)
    }
}

try await forEach(of: values) { element in
    print(element)
}

for try await element in values {
    print(element)
}
