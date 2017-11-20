//
//  MBDataSubscriber.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 18.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import RxSwift

struct HeartRateData {
    let heartRate: UInt
    let timestamp: Int

    var json: [String: Any] {
        return ["heartRate": heartRate, "timestamp": timestamp]
    }
}

class MBDataSubscriber {

    private var client: MSBClient?
    private var heartRateUserConsentGranted = false

    private var heartRates = [HeartRateData]()
    private lazy var hearRateDataUpdateHandler: (MSBSensorHeartRateData?, Error?) -> Void = {
        if let error = $1 {
            log.error(error)
        }

        
        if let heartRate = $0?.heartRate {
            let heartRateData = HeartRateData(
                heartRate: heartRate,
                timestamp: Int(Date().timeIntervalSince1970)
            )
            self.heartRates.append(heartRateData)
        }
    }

    private var connection: MBConnection
    private var dataStore: MBDataStore
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(connection: MBConnection, dataStore: MBDataStore) {
        self.dataStore = dataStore
        self.connection = connection
        self.connection.start()

        self.connection.client
            .subscribe(onNext: { [weak self] in
                self?.setupClient($0)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Public Functions

    func startHeartRateUpdates() -> Bool {
        guard let client = client, heartRateUserConsentGranted else {
            return false
        }

        do {
            try client.sensorManager.startHeartRateUpdates(
                to: nil,
                withHandler: hearRateDataUpdateHandler
            )
        } catch {
            log.error(error)
            return false
        }

        return true
    }

    func stopHeartRateUpdates() {
        dataStore.saveHeartRates(heartRates)
        heartRates = []
    }

    // MARK: - Private Functions

    private func setupClient(_ client: MSBClient) {
        self.client = client
        verifyHeartRateUserConsent { [weak self] in
            self?.heartRateUserConsentGranted = $0
        }
    }

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
                completion(consent)
            }
        case .declined:
            completion(false)
        }
    }

    private func handleHeartRateUpdate(_ heartRateDataUpdate: MSBSensorHeartRateData?) {

    }
}
