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
        ContentView()
    }
}
