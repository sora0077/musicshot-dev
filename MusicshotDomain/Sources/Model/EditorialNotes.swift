//
//  EditorialNotes.swift
//  MusicshotDomain
//
//  Created by 林達也 on 2018/06/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation

open class EditorialNotes {
    /// Notes shown when the content is being prominently displayed.
    open var standard: String { fatalError("abstract") }
    /// Abbreviated notes shown in-line or when the content is shown alongside other content.
    open var short: String { fatalError("abstract") }
}
