//
//  GSRSubscriber.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 22.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import RxSwift

private let gsrKey = "gsr"
private let gsrThreshold = 15000

class GSRSubscriber: MBDataSubscriber {

    var gsrTooHigh = PublishSubject<Void>()

    private lazy var gsrUpdateHandler: (MSBSensorGSRData?, Error?) -> Void = {
        if let error = $1 {
            log.error(error)
        }

        if let resistance = $0?.resistance, self.shouldWriteDate {
            if resistance > gsrThreshold {
//                self.gsrTooHigh.onNext(())
            } else {
                self.data[Date().stringTimeIntervalSince1970InMilliseconds] = resistance
            }
        }
    }

    // MARK: - MBDataSubscriber Conformance

    var shouldWriteDate = true
    var client: MSBClient?
    let dataKey = gsrKey
    var data = [String: Any]()

    // MARK: - Public Functions

    func startUpdates() {
        shouldWriteDate = true
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
        do {
            try client?.sensorManager.stopGSRUpdatesErrorRef()
        } catch {
            log.error(error)
        }
    }

}
