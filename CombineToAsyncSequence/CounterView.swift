import SwiftUI
import UIKit
import Combine
import AsyncAlgorithms
import AudioToolbox

struct CounterView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CounterViewController {
        CounterViewController()
    }

    func updateUIViewController(_ uiViewController: CounterViewController, context: Context) {
    }
}

final class CounterViewController: UIViewController {
    private let state: CounterViewState = .init()

    private var cancellables: Set<AsyncCancellable> = []

    deinit {
        AudioServicesPlaySystemSound(1001)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let countLabel: UILabel = .init()
        countLabel.text = "0"

        let countUpButton: UIButton = .init(type: .system)
        countUpButton.setTitle("Count Up", for: .normal)

        let vStack: UIStackView = .init(arrangedSubviews: [
            countLabel,
            countUpButton,
        ])
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.alignment = .center

        self.view.addSubview(vStack)

        NSLayoutConstraint.activate([
            vStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        countUpButton.addAction(.init { [weak self] _ in
            guard let self else { return }
            Task {
                await self.state.countUp()
            }
        }, for: .touchUpInside)

//        state.$count
//            .map { $0.description }
//            .assign(to: \.text, on: countLabel)
//            .store(in: &cancellables)

        Task { [weak self] in
            guard let state = self?.state else { return }
            for await count in state.count {
                countLabel.text = count.description
            }
        }
        .store(in: &cancellables)

//        state.playSound
//            .sink { _ in
//                AudioServicesPlaySystemSound(1000)
//            }
//            .store(in: &cancellables)

        Task { [weak self] in
            guard let state = self?.state else { return }
            for await _ in state.playSound {
                AudioServicesPlaySystemSound(1000)
            }
        }
        .store(in: &cancellables)
    }
}

@MainActor
final class CounterViewState: ObservableObject {
//    let count: CurrentValueSubject<Int, Never> = .init(0)
    let count: AsyncStore<Int> = .init(0)

//    let playSound: PassthroughSubject<Void, Never> = .init()
    let playSound: AsyncChannel<Void> = .init()

    func countUp() async {
        count.value += 1
        if count.value.isMultiple(of: 10) {
            await playSound.send(())
        }
    }
}

//@MainActor
//final class CounterViewState: Observable {
////    let count: CurrentValueSubject<Int, Never> = .init(0)
//    var count: Int = 0
//
////    let playSound: PassthroughSubject<Void, Never> = .init()
//    let playSound: AsyncChannel<Void> = .init()
//
//    func countUp() async {
//        count += 1
//        if count.isMultiple(of: 10) {
//            await playSound.send(())
//        }
//    }
//}

final class AsyncStore<Value: Sendable>: AsyncSequence {
    typealias Element = Value

    var value: Value {
        didSet {
            let channel = self.channel
            let value = self.value
            Task {
                await channel.send(value)
            }
        }
    }
    private let channel: AsyncChannel<Value> = .init()
    init(_ value: Value) {
        self.value = value
    }

    func makeAsyncIterator() -> AsyncChannel<Value>.AsyncIterator {
        channel.makeAsyncIterator()
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView()
    }
}
