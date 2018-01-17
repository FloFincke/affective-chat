//
//  Constants.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation

enum Constants {

    static let cancelTrackingSeconds: Double = 10

    enum UserDefaults {
        static let initialContentCreatedKey = "initialContentCreated"
        static let tokenKey = "token"
        static let usernameKey = "username"
        static let phoneIdKey = "phoneId"
    }


    enum TrackingInfos {
        static let lastSilentPushKey = "lastSilentPush"
        static let notConnectedKey = "notConnected"
        static let alreadyTrackingKey = "alreadyTracking"
        static let lastDataSentKey = "lastDataSent"
        static let lastDataSentSuccessfulKey = "lastDataSentSuccessful"
        static let lastCancelledKey = "lastCancelled"
        static let trackingEndTimestampKey = "trackingEndTimestampKey"
        static let cancelTrackingTimestampKey = "cancelTrackingTimestamp"
    }

    enum Notifications {
        static let labelsUpdatedNotification = Notification.Name("LabelsUpdated")
    }

    enum DateFormat {
        static let messageTimestamp = "yyyy-MM-dd HH:mm:ss"
        static let fileTimestamp = "yyyy-MM-dd_HH-mm-ss"
        static let messageCell = "yyyy/MM/dd HH:mm"
        static let trackingInfo = "HH:mm dd.MM.yyyy"
    }
    
}
