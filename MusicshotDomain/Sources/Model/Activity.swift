//
//  Activity.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class Activity {
    /// The activity artwork.
    open var artwork: Artwork { fatalError("abstract") }
    /// (Optional) The notes about the activity that appear in the iTunes Store.
    open var editorialNotes: EditorialNotes? { fatalError("abstract") }
    /// The localized name of the activity.
    open var name: String { fatalError("abstract") }
    /// The URL for sharing an activity in the iTunes Store.
    open var url: URL { fatalError("abstract") }
}
