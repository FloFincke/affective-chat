//
//  DataCollectionCycle.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 21.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import RxSwift

enum Receptivity: Int {
    case unknown = -1
    case notReceptible = 0
    case receptible = 1
}

class DataCollectionCycle {

    private var trackingStopped = false
    private var isReady = true
    private var userDefaults = UserDefaults.standard
    private let disposeBag = DisposeBag()

    // MARK: - Services

    private var notificationHandler: NotificationHandler
    private var bandConnection: MBConnection
    private var bandDataStore: MBDataStore
    private var dataSubscriptionContainer: MBDataSubscriptionContainer
    private var geolocationService: GeolocationService
    
    // MARK: - Lifecycle
    
    init(notificationHandler: NotificationHandler,
         bandConnection: MBConnection,
         bandDataStore: MBDataStore,
         dataSubscriptionContainer: MBDataSubscriptionContainer,
         geolocationService: GeolocationService) {
        
        self.notificationHandler = notificationHandler
        self.bandConnection = bandConnection
        self.bandDataStore = bandDataStore
        self.dataSubscriptionContainer = dataSubscriptionContainer
        self.geolocationService = geolocationService

        self.notificationHandler.userReceptivity
            .subscribe(onNext: { [weak self] in self?.stop(receptivity: $0) })
            .disposed(by: disposeBag)

        self.dataSubscriptionContainer.trackingUpdate
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                if !strongSelf.trackingStopped && strongSelf.shouldStopWritingData() {
                    strongSelf.trackingStopped = true
                    strongSelf.dataSubscriptionContainer.stopWritingData()
                }
                if strongSelf.shouldStopTracking() {
                    strongSelf.stop(receptivity: .unknown)
                }
            })
            .disposed(by: disposeBag)

        self.dataSubscriptionContainer.trackingCancelled
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.cancel()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Functions

    func start(withDuration duration: Double, timeoutAfter timeout: Double) {
        guard dataSubscriptionContainer.isConnected else {
            log.warning("Not connected to client")
            UserDefaults.standard.setValue(Date(), forKey: Constants.notConnectedKey)
            return
        }

        guard isReady else {
            log.warning("Another cycle is still active")
            UserDefaults.standard.setValue(Date(), forKey: Constants.alreadyTrackingKey)
            return
        }

        log.info("starting cycle with duration: \(duration) and timeout: \(timeout)")

        isReady = false
        trackingStopped = false

        dataSubscriptionContainer.startSubscriptions()
        notificationHandler.scheduleIsReceptibleNotification(inSeconds: duration)

        let trackingEndTimestamp = Date().addingTimeInterval(duration)
        UserDefaults.standard.setValue(
            trackingEndTimestamp,
            forKey: Constants.trackingEndTimestampKey
        )

        let cancelTimestamp = Date().addingTimeInterval(duration + timeout)
        UserDefaults.standard.setValue(
            cancelTimestamp,
            forKey: Constants.cancelTrackingTimestampKey
        )
    }

    // MARK: - Private Functions

    private func shouldStopWritingData() -> Bool {
        let dateValue = UserDefaults.standard.value(forKey: Constants.trackingEndTimestampKey)
        if let date = dateValue as? Date {
            let timeLeft: Double = date.timeIntervalSinceNow
            let minutes = Int(timeLeft / 60)
            let seconds = String(format: "%02d",
                                 Int(timeLeft.truncatingRemainder(dividingBy: 60).rounded()))
            log.verbose("\(minutes):\(seconds)")
            
            if timeLeft <= 0 {
                return true
            }
        }

        return false
    }

    private func shouldStopTracking() -> Bool {
        let dateValue = UserDefaults.standard.value(forKey: Constants.cancelTrackingTimestampKey)
        if let date = dateValue as? Date, date.timeIntervalSinceNow <= 0 {
            return true
        }

        return false
    }

    private func stop(receptivity: Receptivity) {
        dataSubscriptionContainer.stopSubscriptions()

        geolocationService.start()
        geolocationService.location.asObservable().take(1)
            .flatMap(weak: self) { strongSelf, location -> Observable<Void> in
                strongSelf.geolocationService.stop()
                return strongSelf.bandDataStore.uploadSensorData(
                    withReceptivity: receptivity,
                    atLocation: location
                )
            }
            .subscribe(onNext: {
                UserDefaults.standard.set(true, forKey: Constants.lastDataSentSuccessfulKey)
            }, onError: {
                log.error($0)
                UserDefaults.standard.set(false, forKey: Constants.lastDataSentSuccessfulKey)
            }, onDisposed: { [weak self] in
                self?.isReady = true
                UserDefaults.standard.setValue(Date(), forKey: Constants.lastDataSentKey)
            })
            .disposed(by: disposeBag)
    }

    private func cancel() {
        UserDefaults.standard.setValue(Date(), forKey: Constants.lastCancelledKey)

        notificationHandler.cancelIsReceptibleNotification()
        dataSubscriptionContainer.stopWritingData()
        dataSubscriptionContainer.stopSubscriptions()
        bandDataStore.deleteSensorDataJson()
        isReady = true
    }
    
}
