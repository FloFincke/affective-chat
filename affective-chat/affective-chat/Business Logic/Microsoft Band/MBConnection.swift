//
//  MBConnection.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 18.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import RxSwift

class MBConnection: NSObject {

    var client = PublishSubject<MSBClient>()
    private var isStarted = false
    private var clientManager: MSBClientManager

    // MARK: - Lifecycle

    override init() {
        clientManager = MSBClientManager.shared()
        super.init()
        clientManager.delegate = self
    }

    // MARK: - Public Functions

    func start() {
        guard !isStarted else {
            return
        }

        guard let attachedClients = clientManager.attachedClients() else {
            return
        }

        guard let client = attachedClients.first as? MSBClient else {
            return
        }

        isStarted = true
        clientManager.connect(client)
    }

}

// MARK: - MSBClientManagerDelegate
extension MBConnection: MSBClientManagerDelegate {

    func clientManager(_ clientManager: MSBClientManager!,
                       clientDidConnect client: MSBClient!) {
        self.client.onNext(client)
    }

    func clientManager(_ clientManager: MSBClientManager!,
                       clientDidDisconnect client: MSBClient!) {
        dlog()
    }

    func clientManager(_ clientManager: MSBClientManager!,
                       client: MSBClient!, didFailToConnectWithError error: Error!) {
        dlog()
    }
}
