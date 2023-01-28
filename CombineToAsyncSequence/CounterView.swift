import SwiftUI
import UIKit
import Combine
import AudioToolbox
import AsyncAlgorithms

struct CounterView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CounterViewController {
        CounterViewController()
    }

    func updateUIViewController(_ uiViewController: CounterViewController, context: Context) {
    }
}

final class CounterViewController: UIViewController {
    private let state: CounterViewState = .init()

    private var cancellables: Set<AnyCancellable> = []

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

        view.addSubview(vStack)

        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            vStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        countUpButton.addAction(.init { [weak self] _ in
            guard let self else { return }
            self.state.countUp()
        }, for: .touchUpInside)

//        state.count
//            .map { $0.description }
//            .assign(to: \.text, on: countLabel)
//            .store(in: &cancellables)

//        let task = Task { [weak self] in
//            guard let state = self?.state else { return }
//            for await count in state.count.values {
//                countLabel.text = count.description
//            }
//        }
//        cancellables.insert(.init { task.cancel() })

//        Task { [weak self] in
//            guard let state = self?.state else { return }
//            for await count in state.count.values {
//                countLabel.text = count.description
//            }
//        }
//        .store(in: &cancellables)

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

//        Task { [weak self] in
//            guard let state = self?.state else { return }
//            for await _ in state.playSound.values {
//                AudioServicesPlaySystemSound(1000)
//            }
//        }
//        .store(in: &cancellables)

        Task { [weak self] in
            guard let state = self?.state else { return }
            for await _ in state.playSound {
                AudioServicesPlaySystemSound(1000)
            }
        }
        .store(in: &cancellables)
    }
}

extension Task {
    func store(in cancellables: inout Set<AnyCancellable>) {
        cancellables.insert(.init { cancel() })
    }
}

@MainActor
final class CounterViewState: ObservableObject {
//    let count: CurrentValueSubject<Int, Never> = .init(0)
    let count: AsyncStore<Int> = .init(0)
//    let playSound: PassthroughSubject<Void, Never> = .init()
    let playSound: AsyncChannel<Void> = .init()

    func countUp() {
        count.value += 1
        if count.value.isMultiple(of: 10) {
//            playSound.send(())
            Task {
                await playSound.send(())
            }
        }
    }
}

final class AsyncStore<Value>: AsyncSequence {
    typealias Element = Value

    private let channel: AsyncChannel<Value> = .init()

    var value: Value {
        didSet {
            Task { await channel.send(value) }
        }
    }

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
