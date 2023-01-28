import SwiftUI
import Combine
import AsyncAlgorithms
import AudioToolbox

struct SoundView: View {
    @StateObject private var state: SoundViewState1 = .init()

    var body: some View {
        HStack(spacing: 40) {
            Button("Play 1") {
                state.play1()
            }
            Button("Play 2") {
                state.play2()
            }
        }
        .onReceive(state.playSound) { _ in
            AudioServicesPlaySystemSound(1000)
        }
    }
}

extension View {
    func onReceive<Stream: AsyncSequence>(_ stream: Stream, _ operation: @escaping (Stream.Element) -> Void) -> some View {
        modifier(OnReceive(stream: stream, operation: operation))
    }
}
private struct OnReceive<Stream: AsyncSequence>: ViewModifier {
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
    private let playInput1: PassthroughSubject<Void, Never> = .init()
    private let playInput2: PassthroughSubject<Void, Never> = .init()
    var playSound: some Publisher<Void, Never> {
        playInput1.combineLatest(playInput2).map { _ in () }
    }

    func play1() {
        playInput1.send(())
    }

    func play2() {
        playInput2.send(())
    }
}

@MainActor
final class SoundViewState2: ObservableObject {
    private let playInput1: AsyncChannel<Void> = .init()
    private let playInput2: AsyncChannel<Void> = .init()
    var playSound: some AsyncSequence {
        combineLatest(playInput1, playInput2).map { _ in () }
    }

    func play1() {
        Task { await playInput1.send(()) }
    }

    func play2() {
        Task { await playInput2.send(()) }
    }
}

struct SoundView_Previews: PreviewProvider {
    static var previews: some View {
        SoundView()
    }
}
