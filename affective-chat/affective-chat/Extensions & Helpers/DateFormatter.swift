//
//  File.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 17.01.18.
//  Copyright © 2018 Florian Fincke. All rights reserved.
//

import Foundation

extension DateFormatter {

    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }

    static func forMessageTimestamp() -> DateFormatter {
        return DateFormatter(dateFormat: Constants.DateFormat.messageTimestamp)
    }
}
