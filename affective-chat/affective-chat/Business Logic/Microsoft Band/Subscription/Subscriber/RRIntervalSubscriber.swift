//
//  RRIntervalSubscriber.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 22.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation

private let rrIntervalKey = "rrInterval"

class RRIntervalSubscriber: MBDataSubscriber {

    private lazy var rrIntervalUpdateHandler: (MSBSensorRRIntervalData?, Error?) -> Void = {
        if let error = $1 {
            log.error(error)
        }

        if let interval = $0?.interval, self.shouldWriteDate {
            self.data[Date().stringTimeIntervalSince1970InMilliseconds] = interval
        }
    }

    // MARK: - MBDataSubscriber Conformance

    var shouldWriteDate = true
    var client: MSBClient?
    let dataKey = rrIntervalKey
    var data = [String: Any]()

    // MARK: - Public Functions

    func startUpdates() {
        shouldWriteDate = true
        do {
            try client?.sensorManager.startRRIntervalUpdates(
                to: nil,
                withHandler: rrIntervalUpdateHandler
            )
        } catch {
            log.error(error)
        }
    }

    func stopUpdates() {
        try? client?.sensorManager.stopRRIntervalUpdatesErrorRef()
    }

}
