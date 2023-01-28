import SwiftUI
import Combine
import AsyncAlgorithms
import AudioToolbox

struct SoundView: View {
    @StateObject private var state: SoundViewState1 = .init()

    var body: some View {
        Button("Play") {
            state.play()
        }
        .onReceive(state.playSound) {
            AudioServicesPlaySystemSound(1000)
        }
    }
}

extension View {
    func onReceive<Stream: AsyncSequence>(_ stream: Stream, _ operation: @escaping (Stream.Element) -> Void) -> some View where Stream.Element: Sendable {
        modifier(OnReceive(stream: stream, operation: operation))
    }
}
private struct OnReceive<Stream: AsyncSequence>: ViewModifier where Stream.Element: Sendable {
    let stream: Stream
    let operation: (Stream.Element) -> Void

    func body(content: Content) -> some View {
        content
            .task {
                do {
                    for try await element in stream {
                        operation(element)
                    }
                } catch {
                    print(error)
                }
            }
    }
}

@MainActor
final class SoundViewState1: ObservableObject {
    private let playInput: PassthroughSubject<Void, Never> = .init()
    var playSound: some Publisher<Void, Never> {
        playInput.debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
    }

    func play() {
        playInput.send(())
    }
}

@MainActor
final class SoundViewState2: ObservableObject {
    private let playInput: AsyncChannel<Void> = .init()
    var playSound: AsyncDebounceSequence<AsyncChannel<Void>, ContinuousClock> {
        playInput.debounce(for: .seconds(1.0))
    }

    func play() {
        Task { await playInput.send(()) }
    }
}

struct SoundView_Previews: PreviewProvider {
    static var previews: some View {
        SoundView()
    }
}
