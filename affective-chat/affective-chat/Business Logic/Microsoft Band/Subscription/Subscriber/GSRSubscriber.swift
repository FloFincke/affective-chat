//
//  GSRSubscriber.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 22.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation

private let gsrKey = "gsr"

class GSRSubscriber: MBDataSubscriber {

    private lazy var gsrUpdateHandler: (MSBSensorGSRData?, Error?) -> Void = {
        if let error = $1 {
            log.error(error)
        }

        if let resistance = $0?.resistance {
            self.data[Date().stringTimeIntervalSince1970InMilliseconds] = resistance
        }
    }

    // MARK: - MBDataSubscriber Conformance

    var client: MSBClient?
    let dataKey = gsrKey
    var data = [String: Any]()

    // MARK: - Public Functions

    func startUpdates() {
        do {
            try client?.sensorManager.startGSRUpdates(
                to: nil,
                withHandler: gsrUpdateHandler
            )
        } catch {
            log.error(error)
        }
    }

    func stopUpdates() {
        try? client?.sensorManager.stopGSRUpdatesErrorRef()
    }

}
