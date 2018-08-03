//
//  Artwork.swift
//  MusicshotDomain
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class Artwork {
    public init() {}

    /// The maximum width available for the image.
    open var width: Int { abstract() }
    /// The maximum height available for the image.
    open var height: Int { abstract() }
    /// The URL to request the image asset. The image file name must be preceded by {w}x{h}, as placeholders for the width and height values described above (for example, {w}x{h}bb.jpg).
    open var url: URL { abstract() }
    /// (Optional) The average background color of the image.
    open var bgColor: UIColor? { abstract() }
    /// (Optional) The primary text color that may be used if the background color is displayed.
    open var textColor1: UIColor? { abstract() }
    /// (Optional) The secondary text color that may be used if the background color is displayed.
    open var textColor2: UIColor? { abstract() }
    /// (Optional) The tertiary text color that may be used if the background color is displayed.
    open var textColor3: UIColor? { abstract() }
    /// (Optional) The final post-tertiary text color that maybe be used if the background color is displayed.
    open var textColor4: UIColor? { abstract() }

    /// Indicates if the object can no longer be accessed because it is now invalid.
    open var isInvalidated: Bool { abstract() }
}
