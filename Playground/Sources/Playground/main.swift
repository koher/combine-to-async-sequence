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

let subject: CurrentValueSubject<Int, Never> = .init(42)
var cancellables: Set<AnyCancellable> = []

subject.sink { value in
    print(value)
}
.store(in: &cancellables)

subject.send(999)
