//
//  DataCollectionCycle.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 21.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

enum Receptivity: Int {
    case unknown = -1
    case notReceptible = 0
    case receptible = 1
}

private let receptivityKey = "receptivity"
private let locationKey = "location"

class DataCollectionCycle {

    private var isTracking = false
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
                if self?.shouldStopTracking() ?? true {
                    self?.stop(receptivity: .unknown)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Functions

    func start(withDuration duration: Double) {
        guard dataSubscriptionContainer.isConnected else {
            log.info("Not connected to client")
            return
        }

        guard !isTracking else {
            log.info("Another cycle is still active")
            return
        }
        isTracking = true

        dataSubscriptionContainer.startSubscriptions()
        notificationHandler.scheduleIsReceptibleNotification(inSeconds: duration)

        let cancelTimestamp = Date().addingTimeInterval(duration + Constants.cancelTrackingSeconds)
        UserDefaults.standard.setValue(
            cancelTimestamp,
            forKey: Constants.cancelTrackingTimestampKey
        )
        UserDefaults.standard.synchronize()
    }

    // MARK: - Private Functions

    private func shouldStopTracking() -> Bool {
        let dateValue = UserDefaults.standard.value(forKey: Constants.cancelTrackingTimestampKey)
        if let date = dateValue as? Date, date.timeIntervalSinceNow < 0 {
            return true
        }

        return false
    }

    private func stop(receptivity: Receptivity) {
        dataSubscriptionContainer.stopSubscriptions()

        geolocationService.start()
        geolocationService.location.asObservable().take(1)
            .flatMap { [weak self] location -> Observable<Void> in
                guard let strongSelf = self else { return Observable.just(()) }
                strongSelf.geolocationService.stop()
                strongSelf.prepareSensoreData(
                    receptivity: receptivity,
                    location: location
                )

                return strongSelf.bandDataStore.sendSensorData()
            }
            .subscribe(onDisposed: { [weak self] in
                self?.isTracking = false
            })
            .disposed(by: disposeBag)
    }

    private func prepareSensoreData(receptivity: Receptivity, location: CLLocationCoordinate2D) {
        bandDataStore.saveData(
            [Date().stringTimeIntervalSince1970InMilliseconds: receptivity.rawValue],
            toKey: receptivityKey
        )

        let locationData = ["lat": location.latitude, "long": location.longitude]
        bandDataStore.saveData(
            [Date().stringTimeIntervalSince1970InMilliseconds: locationData],
            toKey: locationKey
        )
    }
}
