//
//  DataCollectionCycle.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 21.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import RxSwift

class DataCollectionCycle {

    private var isTracking = false
    private let disposeBag = DisposeBag()

    // MARK: - Services

    private var notificationHandler: NotificationHandler
    private var bandConnection: MBConnection
    private var bandDataStore: MBDataStore
    private var bandDataSubscriber: MBDataSubscriber
    
    // MARK: - Lifecycle
    
    init(notificationHandler: NotificationHandler,
         bandConnection: MBConnection,
         bandDataStore: MBDataStore,
         bandDataSubscriber: MBDataSubscriber) {
        
        self.notificationHandler = notificationHandler
        self.bandConnection = bandConnection
        self.bandDataStore = bandDataStore
        self.bandDataSubscriber = bandDataSubscriber

        self.notificationHandler.userInteractedWithPush
            .subscribe(onNext: { [weak self] _ in self?.stop() })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Functions

    func start(withDuration duration: Double) {
        guard !isTracking else {
            log.info("Another cycle is still active")
            return
        }
        isTracking = true

        _ = bandDataSubscriber.startHeartRateUpdates()
        notificationHandler.scheduleIsReceptibleNotification(inSeconds: duration)
    }

    // MARK: - Private Functions

    private func stop() {
        bandDataSubscriber.stopHeartRateUpdates()
        bandDataStore.sendSensorData()
    }
}
