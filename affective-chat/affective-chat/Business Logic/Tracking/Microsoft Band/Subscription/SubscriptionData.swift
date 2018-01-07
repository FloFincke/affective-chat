//
//  SubscriptionData.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 22.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation

struct SubscriptionData {
    private var timestamp: String
    private var data: Any

    init(data: Any) {
        self.timestamp = String(format: "%.0f", Date().timeIntervalSince1970 * 1000)
        self.data = data
    }

    var json: Any {
        return [timestamp: data]
    }
}
