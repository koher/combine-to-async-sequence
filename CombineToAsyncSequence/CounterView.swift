import SwiftUI
import UIKit
import Combine
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

    private var cancellables: Set<AnyCancellable> = []

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

        state.$count
            .map { $0.description }
            .assign(to: \.text, on: countLabel)
            .store(in: &cancellables)

        state.playSound
            .sink { _ in
                AudioServicesPlaySystemSound(1000)
            }
            .store(in: &cancellables)
    }
}

@MainActor
final class CounterViewState: ObservableObject {
    @Published private(set) var count: Int = 0
    let playSound: PassthroughSubject<Void, Never> = .init()

    func countUp() {
        count += 1
        if count.isMultiple(of: 10) {
            playSound.send(())
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView()
    }
}
