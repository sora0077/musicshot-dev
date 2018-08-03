//
//  Preview.swift
//  MusicshotDomain
//
//  Created by 林達也.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class Preview {
    public init() {}

    /// The preview URL for the content.
    open var url: URL { abstract() }
    /// (Optional) The preview artwork for the associated music video.
    open var artwork: Artwork? { abstract() }

    /// Indicates if the object can no longer be accessed because it is now invalid.
    open var isInvalidated: Bool { abstract() }
}
