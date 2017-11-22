//
//  MBDataSubscriberFactory.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 22.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation

enum SubscriptionType {
    case heartRate
    case gsr
    case skinTemperature
    case rrInterval
    case motionType

    static var all: [SubscriptionType] {
        return [heartRate, gsr, skinTemperature, rrInterval, motionType]
    }
}

class MBDataSubscriberFactory {

    // MARK: - Public Functions

    func dataSubscriber(for type: SubscriptionType) -> MBDataSubscriber? {
        switch type {
        case .heartRate:
            return HeartRateSubscriber()

        case .gsr:
            return GSRSubscriber()

        case .skinTemperature:
            return SkinTemperatureSubscriber()

        case .rrInterval:
            return RRIntervalSubscriber()

        case .motionType:
            return MotionTypeSubscriber()
        }
    }
}
