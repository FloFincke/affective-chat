//
//  Date+Helpers.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 22.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation

extension Date {
    var stringTimeIntervalSince1970InMilliseconds: String {
        return String(format: "%.0f", self.timeIntervalSince1970 * 1000)
    }
}
