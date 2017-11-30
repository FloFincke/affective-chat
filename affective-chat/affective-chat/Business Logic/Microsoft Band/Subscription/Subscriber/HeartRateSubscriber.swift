//
//  HeartRateSubscriber.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 22.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import RxSwift

private let heartRatesKey = "heartRates"

class HeartRateSubscriber: MBDataSubscriber {

    var trackingUpdate = PublishSubject<Void>()

    private lazy var hearRateDataUpdateHandler: (MSBSensorHeartRateData?, Error?) -> Void = {
            self.trackingUpdate.onNext(())
            if let error = $1 {
                log.error(error)
            }

            if let heartRate = $0?.heartRate, self.shouldWriteDate {
                self.data[Date().stringTimeIntervalSince1970InMilliseconds] = heartRate
            }
    }

    private var heartRateUserConsentGranted = false

    // MARK: - MBDataSubscriber Conformance

    var shouldWriteDate = true
    var client: MSBClient? {
        didSet {
            guard !heartRateUserConsentGranted else {
                return
            }

            verifyHeartRateUserConsent { [weak self] in
                self?.heartRateUserConsentGranted = $0
            }
        }
    }

    let dataKey = heartRatesKey
    var data = [String: Any]()

    // MARK: - Public Functions

    func startUpdates() {
        guard let client = client, heartRateUserConsentGranted else { return }

        shouldWriteDate = true
        do {
            try client.sensorManager.startHeartRateUpdates(
                to: nil,
                withHandler: hearRateDataUpdateHandler
            )
        } catch {
            log.error(error)
        }
    }

    func stopUpdates() {
        try? client?.sensorManager.stopHeartRateUpdatesErrorRef()
    }

    // MARK: - Private Functions

    private func verifyHeartRateUserConsent(completion: @escaping (Bool) -> Void) {
        guard let client = client else {
            return
        }

        let consent = client.sensorManager.heartRateUserConsent()
        switch consent {
        case .granted:
            completion(true)
        case .notSpecified:
            client.sensorManager.requestHRUserConsent { consent, error in
                if let error = error {
                    log.error(error)
                }
                completion(consent)
            }
        case .declined:
            completion(false)
        }
    }
}
