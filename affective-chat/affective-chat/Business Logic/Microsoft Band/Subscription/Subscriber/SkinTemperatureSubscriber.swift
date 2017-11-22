//
//  SkinTemperatureSubscriber.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 22.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation

private let skinTemperatureKey = "skinTemperature"

class SkinTemperatureSubscriber: MBDataSubscriber {

    private lazy var skinTemperatureUpdateHandler: (MSBSensorSkinTemperatureData?, Error?) -> Void = {
        if let error = $1 {
            log.error(error)
        }

        if let temperature = $0?.temperature {
            self.data[Date().stringTimeIntervalSince1970InMilliseconds] = temperature
        }
    }

    // MARK: - MBDataSubscriber Conformance

    var client: MSBClient?
    let dataKey = skinTemperatureKey
    var data = [String: Any]()

    // MARK: - Public Functions

    func startUpdates() {
        do {
            try client?.sensorManager.startSkinTempUpdates(
                to: nil,
                withHandler: skinTemperatureUpdateHandler
            )
        } catch {
            log.error(error)
        }
    }

    func stopUpdates() {
        try? client?.sensorManager.stopSkinTempUpdatesErrorRef()
    }

}
