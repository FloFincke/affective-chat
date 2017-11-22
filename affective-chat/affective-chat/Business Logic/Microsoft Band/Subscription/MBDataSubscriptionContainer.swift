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

    private var subscribers: [MBDataSubscriber]
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
        self.subscribers = subscriptionTypes.flatMap {
            subscriberFactory.dataSubscriber(for: $0)
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
        for subscriber in subscribers {
            log.debug("starting \(subscriber.name)")
            subscriber.startUpdates()
        }
    }

    func stopSubscriptions() {
        for subscriber in subscribers {
            log.debug("stopping \(subscriber.name)")
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
