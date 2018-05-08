//: [Previous](@previous)

import Foundation
import MusicshotUI

var str = "Hello, playground"

build { view in
    let stepper = UIStepper()
    stepper.sizeToFit()
    view.addArrangedSubview(stepper)

    let stepper2 = UIStepper()
    view.addArrangedSubview(stepper2)
}
