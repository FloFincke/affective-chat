//
//  MBDataSubscriptionContainer.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 22.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import RxSwift

class MBDataSubscriptionContainer {

    var isConnected = false
    var trackingUpdate = PublishSubject<Void>()

    private var subscribers: [MBDataSubscriber]!
    private let disposeBag = DisposeBag()

    // MARK: - Services

    private var connection: MBConnection
    private var dataStore: MBDataStore
    private var subscriberFactory: MBDataSubscriberFactory

    // MARK: - Lifecycle

    init(connection: MBConnection,
         dataStore: MBDataStore,
         subscriberFactory: MBDataSubscriberFactory,
         subscriptionTypes: [SubscriptionType]) {

        self.connection = connection
        self.dataStore = dataStore
        self.subscriberFactory = subscriberFactory
        self.subscribers = subscriptionTypes.flatMap { type -> MBDataSubscriber? in
            let subscriber = subscriberFactory.dataSubscriber(for: type)
            if let heartRateSubscriber = subscriber as? HeartRateSubscriber {
                heartRateSubscriber.trackingUpdate
                    .bind(to: trackingUpdate)
                    .disposed(by: disposeBag)
            }
            return subscriber
        }

        self.connection.start()
        self.connection.client
            .subscribe(onNext: { [weak self] in
                self?.setupClient($0)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Public Functions

    func startSubscriptions() {
        log.info("starting subscriptions")
        for subscriber in subscribers {
            subscriber.startUpdates()
        }
    }

    func stopWritingData() {
        for subscriber in subscribers {
            subscriber.shouldWriteDate = false
        }
    }

    func stopSubscriptions() {
        log.info("stopping subscriptions")
        for subscriber in subscribers {
            subscriber.stopUpdates()
            dataStore.saveData(subscriber.data, toKey: subscriber.dataKey)
            subscriber.data = [:]
        }
    }

    // MARK: - Private Functions

    private func setupClient(_ client: MSBClient) {
        for subscriber in subscribers {
            subscriber.client = client
        }
        isConnected = true
        log.info("Connected to client")
    }

}
