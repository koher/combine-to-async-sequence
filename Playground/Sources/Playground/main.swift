import Foundation
import Combine

//protocol Sequence {
//    associatedtype Iterator: IteratorProtocol
//    func makeIterator() -> Iterator
//}
//
//protocol IteratorProtocol {
//    associatedtype Element
//    mutating func next() -> Element?
//}

//let array: Array<Int> = [2, 3, 5]
//
//var iterator: IndexingIterator<Array<Int>> = array.makeIterator()
//while let element = iterator.next() {
//    print(element)
//}

//for i in array {
//    print(i)
//}

//for i in 0 ..< 100 {
//    print(i)
//}

//let range: Range<Int> = 0 ..< 100
//
//var iterator: some IteratorProtocol<Int> = range.makeIterator()
//while let element = iterator.next() {
//    print(element)
//}

//let url: URL = .init(string: "https://koherent.org/pi/pi1000000.txt")!
//
//var iterator = url.resourceBytes.characters.makeAsyncIterator()
//while let character = try await iterator.next() {
//    print(character, terminator: "")
//}
//print()

//for try await character in url.resourceBytes.characters {
//    print(character, terminator: "")
//}
//print()

//let subject: CurrentValueSubject<Int, Never> = .init(42)
//var cancellables: Set<AnyCancellable> = []
//
//subject.sink { value in
//    print(value)
//}
//.store(in: &cancellables)
//
//subject.send(999)

struct GeneralError: Error {
}

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
    func foo()  throws -> Int {
        if Bool.random() { throw GeneralError() }
        return 42
    }
}

struct B: P {
    func foo() -> Int {
        42
    }
}

struct C: Q {
    func bar() throws -> Int {
        if Bool.random() { throw GeneralError() }
        return 999
    }

    func x() -> A {
        A()
    }
}

struct D: Q {
    func bar() -> Int {
        999
    }

    func x() -> B {
        B()
    }
}

//do {
//    let p = A()
//    print(try p.foo())
//}
//
//do {
//    let p = B()
//    print(p.foo())
//}

func useP<X: P>(_ x: X) rethrows {
    print(try x.foo())
}

try useP(A())
useP(B())

func useQ<Y: Q>(_ y: Y) rethrows {
    print(try y.x().foo())
}

try useQ(C())
useQ(D())


@rethrows
protocol MyAsyncIteratorProtocol<Element> {
    associatedtype Element
    mutating func next() async throws -> Element?
}

@rethrows
protocol MyAsyncSequence<Element> {
    associatedtype Element
    associatedtype AsyncIterator: MyAsyncIteratorProtocol<Element>
    func makeAsyncIterator() -> AsyncIterator
}

struct Pair<Element>: MyAsyncSequence {
    var values: (Element, Element)
    init(_ value0: Element, _ value1: Element) {
        self.values = (value0, value1)
    }
    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(self)
    }
    struct AsyncIterator: MyAsyncIteratorProtocol {
        private let pair: Pair<Element>
        private var index: Int = 0
        init(_ pair: Pair<Element>) {
            self.pair = pair
        }
        mutating func next() -> Element? {
            defer { index += 1 }
            switch index {
            case 0: return pair.values.0
            case 1: return pair.values.1
            default: return nil
            }
        }
    }
}

func forEach<T, S: MyAsyncSequence<T>>(of sequence: S, operation: @escaping (T) throws -> Void) async rethrows {
    var iterator = sequence.makeAsyncIterator()
    while let element = try await iterator.next() {
        try operation(element)
    }
}

let pair: Pair<Int> = .init(2, 3)
await forEach(of: pair) { element in
    print(element)
}
