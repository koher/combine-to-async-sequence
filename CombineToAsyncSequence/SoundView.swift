import SwiftUI
import Combine
import AsyncAlgorithms
import AudioToolbox

struct SoundView: View {
    @StateObject private var state: SoundViewState2 = .init()

    var body: some View {
        Button("Play") {
            state.play()
        }
        .onReceive(state.playSound) { _ in
            AudioServicesPlaySystemSound(1000)
        }
    }
}

extension View {
    func onReceive<Stream: AsyncSequence>(_ stream: Stream, _ operation: @escaping (Stream.Element) -> Void) -> some View {
        self.modifier(OnReceive(stream: stream, operation: operation))
    }
}

struct OnReceive<Stream: AsyncSequence>: ViewModifier {
    let stream: Stream
    let operation: (Stream.Element) -> Void

    func body(content: Content) -> some View {
        content.task {
            do {
                for try await element in stream {
                    operation(element)
                }
            } catch {

            }
        }
    }
}

final class SoundViewState1: ObservableObject {
    private let playInput: PassthroughSubject<Void, Never> = .init()
    var playSound: some Publisher<Void, Never> {
        playInput
            .throttle(for: .seconds(1.0), scheduler: DispatchQueue.main, latest: true)
    }

    func play() {
        playInput.send(())
    }
}

final class SoundViewState2: ObservableObject {
    private let playInput: AsyncChannel<Void> = .init()
    var playSound: some AsyncSequence {
        playInput.throttle(for: .seconds(1.0), latest: true)
    }

    func play() {
        let playInput = self.playInput
        Task {
            await playInput.send(())
        }
    }
}

struct SoundView_Previews: PreviewProvider {
    static var previews: some View {
        SoundView()
    }
}
