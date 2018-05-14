import UIKit
import PlaygroundSupport

public func build(_ maker: (UIStackView) -> Void) {
    let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 375, height: 576))
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.spacing = 12
    maker(stackView)

    let vc = UIViewController()
    stackView.frame = vc.view.bounds
    stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    vc.view.addSubview(stackView)
    vc.view.backgroundColor = .white

    PlaygroundPage.current.liveView = vc
}
