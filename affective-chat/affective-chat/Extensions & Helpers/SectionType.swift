//
//  SectionType.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 04.01.18.
//  Copyright © 2018 Florian Fincke. All rights reserved.
//

import Foundation
import RxDataSources

protocol SectionType: SectionModelType {
    var items: [Item] { get set }
}

extension SectionType {

    var identity: String {
        return ""
    }

    init(original: Self, items: [Item]) {
        self = original
        self.items = items
    }
}
