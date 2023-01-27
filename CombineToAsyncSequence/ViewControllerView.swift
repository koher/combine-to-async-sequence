import SwiftUI
import UIKit

struct ViewControllerView<ViewController: UIViewController>: UIViewControllerRepresentable {
    private let make: (Context) -> ViewController
    private let update: ((ViewController, Context) -> Void)?

    init(
        make: @escaping (Context) -> ViewController,
        update: ((ViewController, Context) -> Void)? = nil
    ) {
        self.make = make
        self.update = update
    }

    func makeUIViewController(context: Context) -> ViewController {
        make(context)
    }

    func updateUIViewController(_ viewController: ViewController, context: Context) {
        update?(viewController, context)
    }
}
