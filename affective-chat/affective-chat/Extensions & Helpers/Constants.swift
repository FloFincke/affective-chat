//
//  Constants.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation

enum Constants {

    static let tokenKey = "token"
    static let usernameKey = "username"
    static let phoneIdKey = "phoneId"
    static let lastSilentPushKey = "lastSilentPush"
    static let notConnectedKey = "notConnected"
    static let alreadyTrackingKey = "alreadyTracking"
    static let lastDataSentKey = "lastDataSent"
    static let lastDataSentSuccessfulKey = "lastDataSentSuccessful"
    static let lastCancelledKey = "lastCancelled"
    static let trackingEndTimestampKey = "trackingEndTimestampKey"
    static let cancelTrackingTimestampKey = "cancelTrackingTimestamp"

    static let cancelTrackingSeconds: Double = 10
    
}
