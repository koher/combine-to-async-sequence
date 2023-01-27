//
//  ContentView.swift
//  CombineToAsyncSequence
//
//  Created by Yuta Koshizawa on 2023/01/28.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var state: ContentViewState = .init()

    var body: some View {
        VStack {
            SecureField("パスワード", text: $state.password)
                .textFieldStyle(.roundedBorder)
            Button("Play") {
                state.play()
            }
        }
        .padding()
    }
}

final class ContentViewController: UIViewController {
    private let state: ContentViewState = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        let passwordField: UITextField = .init()
        passwordField.borderStyle = .roundedRect
        passwordField.placeholder = "パスワード"
        passwordField.isSecureTextEntry = true
        let playButton: UIButton = .init(type: .system)
        playButton.setTitle("Play", for: .normal)
        playButton.addAction(.init { [weak self] _ in
            guard let self else { return }
            self.state.play()
        }, for: .touchUpInside)
        let stackView: UIStackView = .init(arrangedSubviews: [
            passwordField,
            playButton,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        self.view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

import Combine
import AudioToolbox

@MainActor
final class ContentViewState: ObservableObject {
    @Published var password: String = ""

    func play() {
        AudioServicesPlaySystemSound(1000)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        ContentView()
        ViewControllerView(make: { _ in ContentViewController() })
    }
}
