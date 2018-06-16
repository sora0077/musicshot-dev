//
//  Artwork.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class Artwork {
    /// The maximum width available for the image.
    open var width: Int { fatalError("abstract") }
    /// The maximum height available for the image.
    open var height: Int { fatalError("abstract") }
    /// The URL to request the image asset. The image file name must be preceded by {w}x{h}, as placeholders for the width and height values described above (for example, {w}x{h}bb.jpg).
    open var url: URL { fatalError("abstract") }
    /// (Optional) The average background color of the image.
    open var bgColor: UIColor? { fatalError("abstract") }
    /// (Optional) The primary text color that may be used if the background color is displayed.
    open var textColor1: UIColor? { fatalError("abstract") }
    /// (Optional) The secondary text color that may be used if the background color is displayed.
    open var textColor2: UIColor? { fatalError("abstract") }
    /// (Optional) The tertiary text color that may be used if the background color is displayed.
    open var textColor3: UIColor? { fatalError("abstract") }
    /// (Optional) The final post-tertiary text color that maybe be used if the background color is displayed.
    open var textColor4: UIColor? { fatalError("abstract") }
}
